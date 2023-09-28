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
    
    /// A Boolean value indicating whether the current value doesn't exist as an option in the domain.
    ///
    /// In this scenario a ``ComboBoxInput`` should be used instead.
    @State private var fallbackToComboBox = false
    
    /// A Boolean value indicating whether a value is required but missing.
    @State private var requiredValueMissing = false
    
    /// A Boolean value indicating whether the switch is toggled on or off.
    @State private var switchState: Bool = false
    
    /// The value represented by the switch.
    @State private var selectedValue: Bool?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The input configuration of the field.
    private let input: SwitchFormInput
    
    /// Creates a view for a switch input.
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
        if fallbackToComboBox {
            ComboBoxInput(
                featureForm: featureForm,
                element: element,
                noValueLabel: .noValue,
                noValueOption: .show
            )
        } else {
            Group {
                InputHeader(element: element)
                    .padding([.top], elementPadding)
                Toggle(switchState ? input.onValue.name : input.offValue.name, isOn: $switchState)
                    .toggleStyle(.switch)
                    .padding([.horizontal], 5)
                    .formTextInputStyle()
                    .accessibilityIdentifier("\(element.label) Switch")
                InputFooter(element: element, requiredValueMissing: requiredValueMissing)
            }
            .padding([.bottom], elementPadding)
            .onAppear {
                if element.value.isEmpty {
                    fallbackToComboBox = true
                } else {
                    switchState = isOn
                }
            }
            .onChange(of: switchState) { newValue in
                let codedValue = newValue ? input.onValue : input.offValue
                featureForm?.feature.setAttributeValue(codedValue.code, forKey: element.fieldName)
            }
        }
    }
}

extension SwitchInput {
    /// A Boolean value indicating whether the switch is toggled on or off.
    ///
    /// Element values are provided as Strings whereas input on/off value codes may be a number of
    /// types. We must cast the element value string to the correct type to perform an accurate check.
    var isOn: Bool {
        switch input.onValue.code {
        case let value as Double:
            return Double(element.value) == value
        case let value as Float:
            return Float(element.value) == value
        case let value as Int:
            return Int(element.value) == value
        case let value as Int8:
            return Int8(element.value) == value
        case let value as Int16:
            return Int16(element.value) == value
        case let value as Int32:
            return Int32(element.value) == value
        case let value as Int64:
            return Int64(element.value) == value
        case let value as String:
            return element.value == value
        default:
            return false
        }
    }
}
