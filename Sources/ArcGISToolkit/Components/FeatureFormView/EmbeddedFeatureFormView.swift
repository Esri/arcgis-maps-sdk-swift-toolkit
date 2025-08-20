// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

struct EmbeddedFeatureFormView: View {
    /// A Boolean value indicating whether the deprecated FeatureFormView initializer was used.
    @Environment(\.formDeprecatedInitializerWasUsed) var deprecatedInitializerWasUsed
    
    /// The view model for the form.
    @State private var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
    
    /// Initializes a form view.
    /// - Parameter featureForm: The feature form defining the editing experience.
    init(featureForm: FeatureForm) {
        self.embeddedFeatureFormViewModel = EmbeddedFeatureFormViewModel(featureForm: featureForm)
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading) {
                    if deprecatedInitializerWasUsed, !embeddedFeatureFormViewModel.title.isEmpty {
                        FormHeader(title: embeddedFeatureFormViewModel.title)
                        Divider()
                    }
                    ForEach(embeddedFeatureFormViewModel.visibleElements, id: \.self) { element in
                        makeElement(element)
                    }
                    if let attachmentsElement = embeddedFeatureFormViewModel.featureForm.defaultAttachmentsElement {
                        // The Toolkit currently only supports AttachmentsFormElements via the
                        // default attachments element. Once AttachmentsFormElements can be authored
                        // this can call makeElement(_:) instead and makeElement(_:) should have a
                        // case added for AttachmentsFormElement.
                        AttachmentsFeatureElementView(
                            formElement: attachmentsElement,
                            formViewModel: embeddedFeatureFormViewModel
                        )
                    }
                }
            }
            .task {
                for await hasEdits in embeddedFeatureFormViewModel.featureForm.$hasEdits.dropFirst() {
                    if !hasEdits {
                        embeddedFeatureFormViewModel.previouslyFocusedElements.removeAll()
                    }
                }
            }
            .onChange(of: embeddedFeatureFormViewModel.focusedElement) {
                if let focusedElement = embeddedFeatureFormViewModel.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
            .onTitleChange(of: embeddedFeatureFormViewModel.featureForm) { newTitle in
                embeddedFeatureFormViewModel.title = newTitle
            }
            .navigationBarTitleDisplayMode(
                .inline,
                isApplied: !deprecatedInitializerWasUsed
            )
            .navigationTitle(
                embeddedFeatureFormViewModel.title,
                isApplied: !deprecatedInitializerWasUsed
            )
        }
#if os(iOS)
        .scrollDismissesKeyboard(.immediately)
#endif
        .environment(embeddedFeatureFormViewModel)
        .padding([.horizontal])
        .preference(
            key: PresentedFeatureFormPreferenceKey.self,
            value: .init(object: embeddedFeatureFormViewModel.featureForm)
        )
        .task {
            await embeddedFeatureFormViewModel.initialEvaluation()
        }
        .featureFormToolbar(embeddedFeatureFormViewModel.featureForm, isAForm: true)
    }
}

extension EmbeddedFeatureFormView {
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as GroupFormElement:
            GroupFormElementView(element: element) { internalMakeElement($0) }
        default:
            internalMakeElement(element)
        }
    }
    
    /// Makes UI for a field form element or a text form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func internalMakeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as TextFormElement:
            makeTextElement(element)
        case let element as UtilityAssociationsFormElement:
            if !deprecatedInitializerWasUsed {
                makeUtilityAssociationsFormElement(element)
            }
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
        if !(element.input is UnsupportedFormInput) {
            FormElementWrapper(element: element)
            Divider()
        }
    }
    
    /// Makes UI for a text form element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeTextElement(_ element: TextFormElement) -> some View {
        TextFormElementView(element: element)
        Divider()
    }
    
    /// Makes UI for a utility associations element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeUtilityAssociationsFormElement(_ element: UtilityAssociationsFormElement) -> some View {
        FormElementWrapper(element: element)
        Divider()
    }
}
