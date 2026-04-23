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
import TipKit

struct EmbeddedFeatureFormView: View {
    /// The model for the FeatureFormView containing the view.
    @Environment(FeatureFormViewModel.self) var featureFormViewModel: FeatureFormViewModel
    
    /// The feature form defining the editing experience.
    let form: FeatureForm
    /// A tip to help users discover the form assistant.
    let formAssistantTip = FormAssistantTip()
    
    var body: some View {
        if let embeddedFeatureFormViewModel {
            ScrollViewReader { scrollView in
                Group {
                    let form = Form { sections }
#if RELEASE
                    form
#else
                    if CommandLine.arguments.contains("-testCase") {
                        @Bindable var model = embeddedFeatureFormViewModel
                        form
                            .searchable(
                                text: $model.elementFilterPhrase,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: Text(
                                    "Filter Elements",
                                    bundle: .toolkitModule,
                                    comment: """
                                        Label for a text field used to 
                                        filter visible elements in a form.
                                        """
                                )
                            )
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
            .overlay(alignment: .bottomLeading) {
                if #available(iOS 26.0, *),
                   EmbeddedFeatureFormViewModel.FormAssistantModel.isAvailable {
                    Button {
                        if embeddedFeatureFormViewModel.formAssistantModel?.isRecording ?? false {
                            Task {
                                await embeddedFeatureFormViewModel.formAssistantModel?.stopSpeechRecognition()
                            }
                        } else {
                            embeddedFeatureFormViewModel.formAssistantModel?.startSpeechRecognition()
                        }
                    } label: {
                        Group {
                            if embeddedFeatureFormViewModel.formAssistantModel?.languageModelIsProcessing ?? false {
                                ProgressView()
                            } else {
                                if embeddedFeatureFormViewModel.formAssistantModel?.isRecording ?? false {
                                    Label {
                                        Text(
                                            "Stop Recording",
                                            bundle: .toolkitModule,
                                            comment: "A label for a button to stop speech detection."
                                        )
                                    } icon: {
                                        Image(systemName: "microphone.badge.xmark.fill")
                                    }
                                    .symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                                    .symbolRenderingMode(.multicolor)
                                } else {
                                    Label {
                                        Text(
                                            "Start Recording",
                                            bundle: .toolkitModule,
                                            comment: "A label for a button to start speech detection."
                                        )
                                    } icon: {
                                        Image(systemName: "microphone.fill")
                                    }
                                }
                            }
                        }
                        // Lock the button's size when the icon changes
                        .frame(idealWidth: 34, idealHeight: 44)
                        .fixedSize()
                        .font(.largeTitle)
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(embeddedFeatureFormViewModel.formAssistantModel?.languageModelIsProcessing ?? false)
                    .sensoryFeedback(
                        .impact,
                        trigger: embeddedFeatureFormViewModel.formAssistantModel?.isRecording
                    )
                    .shadow(radius: 8)
                    .padding(.leading)
                    .popoverTip(formAssistantTip)
                    .task(id: ObjectIdentifier(embeddedFeatureFormViewModel)) {
                        embeddedFeatureFormViewModel.prepareFormAssistant()
                    }
                }
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
            } footer: {
                FormElementFooter(element: element)
                    .padding(.bottom)
            }
            .textCase(nil)
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
