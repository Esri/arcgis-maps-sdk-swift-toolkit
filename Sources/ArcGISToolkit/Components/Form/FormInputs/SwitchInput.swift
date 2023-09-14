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

struct SwitchInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: SwitchFormInput
    
    @State private var value: Bool?
    
    @State private var switchState: Bool = false
    
    /// Creates a view for a Switch input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: SwitchFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
    
    var body: some View {
        Group {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            Toggle(element.label, isOn: $switchState)
                .toggleStyle(.switch)
            footer
        }
        .padding([.bottom], elementPadding)
        .onAppear {
//            if let value = element.value {  // returns name for CodedValues
//                switchState = (value == input.onValue.name)
//            }
            if let value = featureForm?.feature.attributes[element.fieldName] as? CodedValue {
                switchState = (value.name == input.onValue.name)
            }
        }
        .onChange(of: switchState) { newValue in
            let codedValue = newValue ? input.onValue : input.offValue
            // element.updateValue(codedValue)
            featureForm?.feature.setAttributeValue(codedValue, forKey: element.fieldName)
        }
    }
    
    /// The message shown below the date editor and viewer.
    @ViewBuilder var footer: some View {
        Text(element.description)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
