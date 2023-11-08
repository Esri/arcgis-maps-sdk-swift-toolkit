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
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
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
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
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
                InputHeader(label: element.label, isRequired: inputModel.isRequired)
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
            .disabled(!inputModel.isEditable)
            .padding([.bottom], elementPadding)
            .onAppear {
                if element.formattedValue.isEmpty {
                    fallbackToComboBox = true
                } else {
                    isOn = input.onValue.name == inputModel.formattedValue
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
            .onChange(of: inputModel.formattedValue) { formattedValue in
                isOn = formattedValue == input.onValue.name
            }
        }
    }
}
