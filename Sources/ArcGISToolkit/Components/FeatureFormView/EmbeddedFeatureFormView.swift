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
                Group {
                    let form = Form {
                        sections
                    }
#if RELEASE
                    form
#else
                    if CommandLine.arguments.contains("-testCase") {
                        // Use a ScrollView and VStack during UI testing
                        // to make all form elements accessible.
                        ScrollView {
                            VStack {
                                sections
                            }
                        }
                    } else {
                        form
                    }
#endif
                }
                .onChange(of: embeddedFeatureFormViewModel.focusedElement) { _, newFocusedElement in
                    guard let newFocusedElement else { return }
                    // The navigation bar may obscure section headers (FB19740517).
                    withAnimation {
                        scrollView.scrollTo(newFocusedElement, anchor: .top)
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
    /// Returns the section for the given form element.
    ///
    /// Padding is added to each footer to provide visual separation between
    /// elements.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func section(for element: FormElement) -> some View {
        switch element {
        case let element as GroupFormElement:
            GroupFormElementView(element: element, viewCreator: content(for:))
        default:
            Section {
                content(for: element)
            } header: {
                FormElementHeader(element: element)
                    .textCase(nil)
            } footer: {
                FormElementFooter(element: element)
                    .padding(.bottom)
                    .textCase(nil)
            }
        }
    }
    
    /// Returns content for the section of the given form element.
    /// - Parameter element: The element to generate the body for.
    @ViewBuilder func content(for element: FormElement) -> some View {
        if let embeddedFeatureFormViewModel {
            switch element {
            case let element as AttachmentsFormElement:
                AttachmentsFeatureElementView(
                    formElement: element,
                    formViewModel: embeddedFeatureFormViewModel
                )
            case let element as FieldFormElement where !(element.input is UnsupportedFormInput):
                FieldFormElementView(element: element)
            case let element as TextFormElement:
                TextFormElementView(element: element)
            case let element as UtilityAssociationsFormElement:
                FeatureFormView.UtilityAssociationsFormElementView(element: element)
            default:
                EmptyView()
            }
        }
    }
    
    /// The sections for all visible form elements.
    @ViewBuilder var sections: some View {
        if let visibleElements = embeddedFeatureFormViewModel?.visibleElements {
            ForEach(visibleElements, id: \.self, content: section(for:))
        } else {
            ContentUnavailableView {
                Label {
                    Text(
                        "This form is empty.",
                        bundle: .toolkitModule,
                        comment: "A notice communicating that a feature form has no elements."
                    )
                } icon: {
                    Image(systemName: "text.page.slash.fill")
                }
            }
        }
    }
}
