// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// Forms allow users to edit information about GIS features.
///
/// - Since: 200.3
public struct FormView: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// The form's configuration.
    private let featureForm: FeatureForm?
    
    /// A Boolean value indicating whether an evaluation is running.
    @State var isEvaluating = true
    
    /// A list of the visible elements in the form.
    @State var visibleElements = [FormElement]()
    
    /// Initializes a form view.
    /// - Parameter featureForm: The form's configuration.
    public init(featureForm: FeatureForm?) {
        self.featureForm = featureForm
    }
    
    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                if isEvaluating {
                    ProgressView()
                } else {
                    VStack(alignment: .leading) {
                        FormHeader(title: featureForm?.title)
                            .padding([.bottom], elementPadding)
                        ForEach(model.visibleElements, id: \.self) { element in
                            makeElement(element)
                        }
                    }
                }
            }
            .onChange(of: model.focusedElement) { focusedElement in
                if let focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
        }
        .scrollDismissesKeyboard()
        .onChange(of: model.visibleElements) { _ in
            visibleElements = model.visibleElements
        }
        .task {
            do {
                isEvaluating = true
                try await featureForm?.evaluateExpressions()
                isEvaluating = false
                model.initializeIsVisibleTasks()
                model.setupGroupModels()
            } catch {
                print("error evaluating expressions: \(error.localizedDescription)")
            }
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
            makeGroupElement(element)
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
        case is TextAreaFormInput:
            MultiLineTextInput(element: element)
        case is RadioButtonsFormInput:
            RadioButtonsInput(element: element)
        case is TextBoxFormInput:
            SingleLineTextInput(element: element)
        case is SwitchFormInput:
            SwitchInput(element: element)
        default:
            EmptyView()
        }
        if element.isVisible {
            Divider()
        }
    }
    
    /// Makes UI for a group form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeGroupElement(_ element: GroupFormElement) -> some View {
        if let groupModel = model.groupElementModels[element.label] {
            DisclosureGroup(element.label/*isExpanded: groupModel.$isExpanded*/) {
                ForEach(element.formElements, id: \.label) { formElement in
                    if let element = formElement as? FieldFormElement {
                        makeFieldElement(element)
                    }
                }
            }
        }
    }
}

private extension View {
    /// - Returns: A view that immediately dismisses the keyboard upon scroll.
    func scrollDismissesKeyboard() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .scrollDismissesKeyboard(.immediately)
        } else {
            return self
        }
    }
}
