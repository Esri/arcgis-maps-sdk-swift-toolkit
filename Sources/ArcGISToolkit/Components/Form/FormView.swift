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
import FormsPlugin
import SwiftUI

/// Forms allow users to edit information about GIS features.
/// - Since: 200.2
public struct FormView: View {
    @Environment(\.formElementPadding) var elementPadding
    
    @EnvironmentObject var model: FormViewModel
    
    /// Initializes a form view.
    public init() {}
    
    public var body: some View {
        ScrollView {
            FormHeader(title: model.formDefinition?.title)
                .padding([.bottom], elementPadding)
            VStack(alignment: .leading) {
                ForEach(model.formDefinition?.formElements ?? [], id: \.element?.label) { container in
                    if let element = container.element {
                        makeElement(element)
                    }
                }
            }
        }
        .task {
            let decoder = JSONDecoder()
            if let layer = feature.table?.layer as? FeatureLayer,
               let formInfoDictionary = layer._unsupportedJSON["formInfo"],
               let jsonData = try? JSONSerialization.data(withJSONObject: formInfoDictionary),
               let formDefinition = try? decoder.decode(FeatureFormDefinition.self, from: jsonData) {
                model.formDefinition = formDefinition
            } else {
                print("Error processing form definition")
            }
        }
    }
}

extension FormView {
    /// The feature being edited in the form.
    private var feature: ArcGISFeature {
        if let feature = model.feature {
            return feature
        } else {
            fatalError("The feature was cleared but the form is still presented.")
        }
    }
    
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FeatureFormElement) -> some View {
        switch element {
        case let element as FieldFeatureFormElement:
            makeFieldElement(element)
        case let element as GroupFeatureFormElement:
            makeGroupElement(element)
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeFieldElement(_ element: FieldFeatureFormElement) -> some View {
        switch element.inputType.input {
        case let `input` as TextBoxFeatureFormInput:
            SingleLineTextEntry(
                element: element,
                text: feature.attributes[element.fieldName] as? String,
                input: `input`
            )
        case let `input` as TextAreaFeatureFormInput:
            MultiLineTextEntry(
                element: element,
                text: feature.attributes[element.fieldName] as? String,
                input: `input`
            )
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a group form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeGroupElement(_ element: GroupFeatureFormElement) -> some View {
        DisclosureGroup(element.label) {
            ForEach(element.formElements, id: \.element?.label) { container in
                if let element = container.element as? FieldFeatureFormElement {
                    makeFieldElement(element)
                }
            }
        }
    }
}
