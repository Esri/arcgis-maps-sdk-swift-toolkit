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
    @Environment(\.formChangedAction) var formChangedAction
    
#warning("elementPadding to be removed when makeUtilityAssociationsFormElement is revised")
    @Environment(\.formElementPadding) var formElementPadding
    
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// The view model for the form.
    @StateObject private var model: FormViewModel
    
    /// A Boolean value indicating whether initial expression evaluation is running.
    @State private var initialExpressionsAreEvaluating = true
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    init(featureForm: FeatureForm) {
        _model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
    }
    
    var body: some View {
        Group {
            if initialExpressionsAreEvaluating {
                initialBody
            } else {
                evaluatedForm
            }
        }
        .onAppear {
            formChangedAction?(model.featureForm)
        }
    }
    
    var evaluatedForm: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(model.visibleElements, id: \.self) { element in
                        makeElement(element)
                    }
                    if let attachmentsElement = model.featureForm.defaultAttachmentsElement {
                        // The Toolkit currently only supports AttachmentsFormElements via the
                        // default attachments element. Once AttachmentsFormElements can be authored
                        // this can call makeElement(_:) instead and makeElement(_:) should have a
                        // case added for AttachmentsFormElement.
                        AttachmentsFeatureElementView(featureElement: attachmentsElement)
                    }
                }
            }
            .onChange(model.focusedElement) { _ in
                if let focusedElement = model.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
            .onTitleChange(of: model.featureForm) { newTitle in
                model.title = newTitle
            }
            .navigationLayerTitle(model.title)
        }
#if os(iOS)
        .scrollDismissesKeyboard(.immediately)
#endif
        .environmentObject(model)
    }
}

extension InternalFeatureFormView {
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as GroupFormElement:
            GroupView(element: element, viewCreator: { internalMakeElement($0) })
        case let element as TextFormElement:
            makeTextElement(element)
        case let element as UtilityAssociationsFormElement:
            makeUtilityAssociationsFormElement(element)
        default:
            EmptyView()
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
            InputWrapper(element: element)
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
        HStack {
            Text(element.label.isEmpty ? "Associations" : element.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, formElementPadding)
        
        UtilityAssociationsFormElementView(element: element)
            .environmentObject(model)
        
        if !element.description.isEmpty {
            Text(element.description)
                .font(.footnote)
        }
        Divider()
    }
    
    /// The progress view to be shown while initial expression evaluation is running.
    ///
    /// This avoids flashing elements that may immediately be set hidden or have
    /// values change as a result of initial expression evaluation.
    var initialBody: some View {
        ProgressView()
            .task {
                await model.initialEvaluation()
                initialExpressionsAreEvaluating = false
            }
    }
}
