// Copyright 2023 Esri
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

/// Forms allow users to edit information about GIS features.
///
/// - Since: 200.4
public struct FormView: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @StateObject private var model: FormViewModel
    
    /// A Boolean value indicating whether the initial expression evaluation is running.
    @State var isEvaluating = true
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - feature: The feature to edit.
    ///   - featureForm: The feature form defining the editing experience.
    public init(feature: ArcGISFeature, featureForm: FeatureForm) {
        _model = StateObject(wrappedValue: FormViewModel(feature: feature, featureForm: featureForm))
    }
    
    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                if isEvaluating {
                    ProgressView()
                } else {
                    VStack(alignment: .leading) {
                        FormHeader(title: model.featureForm.title)
                            .padding([.bottom], elementPadding)
                        ForEach(model.visibleElements, id: \.self) { element in
                            makeElement(element)
                        }
                    }
                }
            }
            .task(id: model.focusedElement) {
                if let focusedElement = model.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
        }
        .scrollDismissesKeyboard(
            // Allow tall multiline text fields to be scrolled
            immediately: (model.focusedElement as? FieldFormElement)?.input is TextAreaFormInput ? false : true
        )
        .environmentObject(model)
        .task {
            // Perform the initial expression evaluation.
            isEvaluating = true
            try? await model.initialEvaluation()
            isEvaluating = false
        }
    }
}

extension FormView {
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as GroupFormElement:
            GroupView(element: element, viewCreator: { makeFieldElement($0) })
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
        switch element.input {
        case is ComboBoxFormInput:
            ComboBoxInput(element: element)
        case is DateTimePickerFormInput:
            DateTimeInput(element: element)
        case is RadioButtonsFormInput:
            RadioButtonsInput(element: element)
        case is SwitchFormInput:
            SwitchInput(element: element)
        case is TextAreaFormInput, is TextBoxFormInput:
            TextInput(element: element)
        default:
            EmptyView()
        }
        // BarcodeScannerFormInput is not currently supported
        if element.isVisible && !(element.input is BarcodeScannerFormInput) {
            Divider()
        }
    }
}

private extension View {
    /// Configures the behavior in which scrollable content interacts with the software keyboard.
    /// - Returns: A view that dismisses the keyboard when the  scroll.
    /// - Parameter immediately: A Boolean value that will cause the keyboard to the keyboard to
    /// dismiss as soon as scrolling starts when `true` and interactively when `false`.
    func scrollDismissesKeyboard(immediately: Bool) -> some View {
        if #available(iOS 16.0, *) {
            return self
                .scrollDismissesKeyboard(immediately ? .immediately : .interactively)
        } else {
            return self
        }
    }
}
