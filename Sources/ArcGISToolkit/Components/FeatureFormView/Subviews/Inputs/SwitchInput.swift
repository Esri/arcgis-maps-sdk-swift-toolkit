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
    /// The view model for the form.
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// A Boolean value indicating whether the initial element value was received.
    @State private var didReceiveInitialValue = false
    
    /// A Boolean value indicating whether the current value doesn't exist as an option in the domain.
    ///
    /// In this scenario a ``ComboBoxInput`` should be used instead.
    @State private var fallbackToComboBox = false
    
    /// A Boolean value indicating whether the switch is toggled on or off.
    @State private var isOn = false
    
    /// The value represented by the switch.
    @State private var selectedValue: Bool?
    
    /// The element the input belongs to.
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
    }
    
    var body: some View {
        if fallbackToComboBox {
            ComboBoxInput(
                element: element,
                noValueLabel: .noValue,
                noValueOption: .show
            )
        } else {
            Toggle(isOn: $isOn) {
                Text(isOn ? input.onValue.name : input.offValue.name)
            }
            .accessibilityIdentifier("\(element.label) Switch")
            .formInputStyle(isTappable: false)
            .onAppear {
                if element.formattedValue.isEmpty {
                    fallbackToComboBox = true
                }
            }
            // This element should only be set as the focused element when a
            // user physically interacts with the toggle.
            //
            // onChange(_:perform:) is not a good signal for detecting user
            // interaction because it may or may not run when the view first
            // loads, depending if the initial value matches the default value
            // defined for `isOn`.
            .onChange(of: isOn) {
                element.updateValue(isOn ? input.onValue.code : input.offValue.code)
                internalFeatureFormViewModel.evaluateExpressions()
            }
            // onValueChange(of:action:) is a good signal for user interaction
            // because it will reliably run when the view first loads and each
            // subsequent time a user changes the value. The only requirement is
            // that we must track the initial run.
            .onValueChange(of: element) { newValue, newFormattedValue in
                isOn = newFormattedValue == input.onValue.name
                if didReceiveInitialValue {
                    internalFeatureFormViewModel.focusedElement = element
                } else {
                    didReceiveInitialValue = true
                }
            }
        }
    }
}
