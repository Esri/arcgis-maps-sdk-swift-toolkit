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

struct InternalFeatureFormView: View {
    /// The environment value to access the closure to call when the presented feature form changes.
    @Environment(\.formChangedAction) var formChangedAction
    
    /// The view model for the form.
    @State private var internalFeatureFormViewModel: InternalFeatureFormViewModel
    
    /// Initializes a form view.
    /// - Parameter featureForm: The feature form defining the editing experience.
    init(featureForm: FeatureForm) {
        self.internalFeatureFormViewModel = InternalFeatureFormViewModel(featureForm: featureForm)
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(internalFeatureFormViewModel.visibleElements, id: \.self) { element in
                        makeElement(element)
                    }
                    if let attachmentsElement = internalFeatureFormViewModel.featureForm.defaultAttachmentsElement {
                        // The Toolkit currently only supports AttachmentsFormElements via the
                        // default attachments element. Once AttachmentsFormElements can be authored
                        // this can call makeElement(_:) instead and makeElement(_:) should have a
                        // case added for AttachmentsFormElement.
                        AttachmentsFeatureElementView(
                            formElement: attachmentsElement,
                            formViewModel: internalFeatureFormViewModel
                        )
                    }
                }
            }
            .task {
                for await hasEdits in internalFeatureFormViewModel.featureForm.$hasEdits.dropFirst() {
                    if !hasEdits {
                        internalFeatureFormViewModel.previouslyFocusedElements.removeAll()
                    }
                }
            }
            .onChange(of: internalFeatureFormViewModel.focusedElement) {
                if let focusedElement = internalFeatureFormViewModel.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
            .onTitleChange(of: internalFeatureFormViewModel.featureForm) { newTitle in
                internalFeatureFormViewModel.title = newTitle
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(internalFeatureFormViewModel.title)
        }
#if os(iOS)
        .scrollDismissesKeyboard(.immediately)
#endif
        .environment(internalFeatureFormViewModel)
        .padding([.horizontal])
        .task {
            await internalFeatureFormViewModel.initialEvaluation()
        }
        .onAppear {
            formChangedAction?(internalFeatureFormViewModel.featureForm)
        }
        .featureFormToolbar(internalFeatureFormViewModel.featureForm, isAForm: true)
    }
}

extension InternalFeatureFormView {
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
            makeUtilityAssociationsFormElement(element)
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
