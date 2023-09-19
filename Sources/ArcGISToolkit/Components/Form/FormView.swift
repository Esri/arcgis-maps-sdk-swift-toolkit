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
/// - Since: 200.3
public struct FormView: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The form's configuration.
    private var featureForm: FeatureForm?
    
    /// Initializes a form view.
    /// - Parameter featureForm: The form's configuration.
    public init(featureForm: FeatureForm?) {
        self.featureForm = featureForm
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FormHeader(title: featureForm?.title)
                    .padding([.bottom], elementPadding)
                ForEach(featureForm?.elements ?? [], id: \.label) { element in
                    makeElement(element)
                }
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
        case let `input` as ComboBoxFormInput:
            ComboBoxInput(featureForm: featureForm, element: element, input: `input`)
        case let `input` as DateTimePickerFormInput:
            DateTimeInput(featureForm: featureForm, element: element, input: `input`)
        case let `input` as TextAreaFormInput:
            MultiLineTextInput(featureForm: featureForm, element: element, input: `input`)
        case let `input` as TextBoxFormInput:
            SingleLineTextInput(featureForm: featureForm, element: element, input: `input`)
        default:
            EmptyView()
        }
        Divider()
    }
    
    /// Makes UI for a group form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeGroupElement(_ element: GroupFormElement) -> some View {
        DisclosureGroup(element.label) {
            ForEach(element.formElements, id: \.label) { formElement in
                if let element = formElement as? FieldFormElement {
                    makeFieldElement(element)
                }
            }
        }
    }
}
