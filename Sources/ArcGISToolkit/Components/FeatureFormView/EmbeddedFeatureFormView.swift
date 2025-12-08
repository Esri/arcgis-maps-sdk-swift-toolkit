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
    /// The model for the FeatureFormView containing the view.
    @Environment(FeatureFormViewModel.self) var featureFormViewModel: FeatureFormViewModel
    
    /// The feature form defining the editing experience.
    let form: FeatureForm
    
    var body: some View {
        if let embeddedFeatureFormViewModel {
            ScrollViewReader { scrollView in
                List(embeddedFeatureFormViewModel.visibleElements, id: \.self) { element in
                    makeElement(element)
                }
                .onChange(of: embeddedFeatureFormViewModel.focusedElement) {
                    if let focusedElement = embeddedFeatureFormViewModel.focusedElement {
                        // Navigation bars will unfortunately cover or obscure
                        // section headers. See FB19740517.
                        withAnimation { scrollView.scrollTo(focusedElement, anchor: .top) }
                    }
                }
            }
            .environment(embeddedFeatureFormViewModel)
            .featureFormToolbar(form, isAForm: true) {
                featureFormViewModel.removeModel(form)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(embeddedFeatureFormViewModel.title)
            .onTitleChange(of: embeddedFeatureFormViewModel.featureForm) { newTitle in
                embeddedFeatureFormViewModel.title = newTitle
            }
            .preference(
                key: PresentedFeatureFormPreferenceKey.self,
                value: .init(object: embeddedFeatureFormViewModel)
            )
#if os(iOS)
            .scrollDismissesKeyboard(.immediately)
#endif
        }
    }
    
    /// The view model for the form.
    var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel? {
        featureFormViewModel.getModel(form)
    }
}

extension EmbeddedFeatureFormView {
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        Section {
            switch element {
            case let element as GroupFormElement:
                GroupFormElementView(element: element) { makeElementBody($0) }
            default:
                makeElementBody(element)
            }
        } header: {
            FormElementHeader(element: element)
                .textCase(.none)
        } footer: {
            FormElementFooter(element: element)
                .textCase(.none)
        }
    }
    
    /// Makes UI for a form element's body.
    /// - Parameter element: The element to generate the body for.
    @ViewBuilder func makeElementBody(_ element: FormElement) -> some View {
        if let embeddedFeatureFormViewModel {
            switch element {
            case let element as AttachmentsFormElement:
                AttachmentsFeatureElementView(
                    formElement: element,
                    formViewModel: embeddedFeatureFormViewModel
                )
            case let element as FieldFormElement:
                if !(element.input is UnsupportedFormInput) {
                    FieldFormElementView(element: element)
                }
            case let element as TextFormElement:
                TextFormElementView(element: element)
            case let element as UtilityAssociationsFormElement:
                FeatureFormView.UtilityAssociationsFormElementView(element: element)
            default:
                EmptyView()
            }
        }
    }
}
