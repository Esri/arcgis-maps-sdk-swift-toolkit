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

/// A view for boolean style input.
///
/// The switch represents two mutually exclusive values, such as: yes/no, on/off, true/false.
struct SwitchInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// State properties for element events.
    @State var isRequired: Bool = false
    @State var isEditable: Bool = false
    @State var value: Any?
    @State var formattedValue: String = ""

    /// A Boolean value indicating whether the current value doesn't exist as an option in the domain.
    ///
    /// In this scenario a ``ComboBoxInput`` should be used instead.
    @State private var fallbackToComboBox = false
    
    /// A Boolean value indicating whether a value is required but missing.
    @State private var requiredValueMissing = false
    
    /// A Boolean value indicating whether the switch is toggled on or off.
    @State private var isOn: Bool = false
    
    /// The value represented by the switch.
    @State private var selectedValue: Bool?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: SwitchFormInput
    
    /// Creates a view for a switch input.
    /// - Parameters:
    ///   - element: The field's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is SwitchFormInput,
            "\(Self.self).\(#function) element's input must be \(SwitchFormInput.self)."
        )
        
        self.element = element
        self.input = element.input as! SwitchFormInput
        
        value = element.value
        formattedValue = element.formattedValue
        isRequired = element.isRequired
        isEditable = element.isEditable
    }
    
    var body: some View {
        if fallbackToComboBox {
            ComboBoxInput(
                element: element,
                noValueLabel: .noValue,
                noValueOption: .show
            )
        } else {
            Group {
                InputHeader(label: element.label, isRequired: isRequired)
                    .padding([.top], elementPadding)
                HStack {
                    Text(isOn ? input.onValue.name : input.offValue.name)
                        .accessibilityIdentifier("\(element.label) Switch Label")
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("\(element.label) Switch")
                }
                .formInputStyle()
                InputFooter(element: element, requiredValueMissing: requiredValueMissing)
            }
            .disabled(!isEditable)
            .padding([.bottom], elementPadding)
            .onAppear {
                if element.formattedValue.isEmpty {
                    fallbackToComboBox = true
                } else {
                    isOn = input.onValue.name == formattedValue
                }
            }
            .onChange(of: isOn) { isOn in
                do {
                    try element.updateValue(isOn ? input.onValue.code : input.offValue.code)
                } catch {
                    print(error.localizedDescription)
                }
                model.evaluateExpressions()
            }
            .onChangeOfValue(of: element) { newValue, newFormattedValue in
                value = newValue
                formattedValue = newFormattedValue
                isOn = formattedValue == input.onValue.name
            }
            .onChangeOfIsRequired(of: element) { newIsRequired in
                isRequired = newIsRequired
            }
            .onChangeOfIsEditable(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
    }
}
