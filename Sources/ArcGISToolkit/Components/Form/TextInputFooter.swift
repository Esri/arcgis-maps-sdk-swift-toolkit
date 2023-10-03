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

import SwiftUI
import ArcGIS

/// A view shown at the bottom of each text input element in a form.
struct TextInputFooter: View {
    /// An error present when a validation constraint is unmet.
    @State private var validationError: TextValidationError?
    
    /// A Boolean value indicating whether the text input field has previously satisfied the minimum
    /// length at any point in time.
    @State private var hasPreviouslySatisfiedMinimum: Bool
    
    /// The current text in the text input field.
    private let text: String
    
    /// The current length of the text in the text input field.
    private let currentLength: Int
    
    /// The footer's parent element.
    private let element: FieldFormElement
    
    /// A Boolean value indicating whether the text input field is focused.
    private let isFocused: Bool
    
    /// The description of the text input field.
    private let description: String
    
    /// A Boolean value indicating whether the text input field is required.
    private let isRequired: Bool
    
    /// The allowable length of text in the text input field.
    private let lengthRange: ClosedRange<Int>
    
    /// The allowable range of numeric values in the text input field.
    private let rangeDomain: RangeDomain?
    
    /// A Boolean value indicating whether the field has a numeric data type.
    private var isNumeric: Bool
    
    /// A Boolean value indicating whether the field has a numeric data type with decimal precision.
    private var isDecimal: Bool
    
    /// Creates a footer shown at the bottom of each text input element in a form.
    /// - Parameters:
    ///   - text: The current text in the text input field.
    ///   - isFocused: A Boolean value indicating whether the text input field is focused.
    ///   - element: The footer's parent element.
    ///   - input: A form input that provides length constraints for the text input.
    ///   - rangeDomain: The allowable range of numeric values in the text input field.
    ///   - isNumeric: A Boolean value indicating whether the field has a numeric data type.
    ///   - isDecimal: A Boolean value indicating whether the field has a numeric data type with decimal precision.
    init(
        text: String,
        isFocused: Bool,
        element: FieldFormElement,
        input: FormInput,
        rangeDomain: RangeDomain? = nil,
        isNumeric: Bool = false,
        isDecimal: Bool = false
    ) {
        self.text = text
        self.currentLength = text.count
        self.element = element
        self.isFocused = isFocused
        self.description = element.description
        self.isRequired = element.isRequired
        self.rangeDomain = rangeDomain
        self.isNumeric = isNumeric
        self.isDecimal = isDecimal
        
        switch input {
        case let input as TextBoxFormInput:
            lengthRange = input.minLength...input.maxLength
            _hasPreviouslySatisfiedMinimum = State(
                initialValue: !isNumeric && currentLength >= input.minLength
            )
        case let input as TextAreaFormInput:
            lengthRange = input.minLength...input.maxLength
            _hasPreviouslySatisfiedMinimum = State(
                initialValue: !isNumeric && currentLength >= input.minLength
            )
        default:
            fatalError("\(Self.self) can only be used with \(TextAreaFormInput.self) or \(TextBoxFormInput.self)")
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if let primaryMessage {
                primaryMessage
                    .accessibilityIdentifier("\(element.label) Footer")
            }
            Spacer()
            if isFocused, description.isEmpty || validationError != nil, !isNumeric {
                Text(currentLength, format: .number)
                    .accessibilityIdentifier("\(element.label) Character Indicator")
            }
        }
        .font(.footnote)
        .foregroundColor(validationError == nil ? .secondary : .red)
        .onChange(of: text) { newText in
            if !hasPreviouslySatisfiedMinimum && !isNumeric {
                if newText.count >= lengthRange.lowerBound {
                    hasPreviouslySatisfiedMinimum = true
                }
            } else {
                validate(text: newText, focused: isFocused)
            }
        }
        .onChange(of: isFocused) { newIsFocused in
            if hasPreviouslySatisfiedMinimum || !newIsFocused {
                validate(text: text, focused: newIsFocused)
            }
        }
    }
}

extension TextInputFooter {
    /// The primary message to be shown in the footer, if any, dependent on the presence of a
    /// validation error, description, and focus state.
    var primaryMessage: Text? {
        switch (validationError, description.isEmpty, isFocused) {
        case (.none, true, true):
            return validationText
        case (.none, true, false):
            return nil
        case (.none, false, _):
            return Text(description)
        case (.some(let validationError), _, _):
            switch (validationError, scheme) {
            case (.emptyWhenRequired, .max):
                return .required
            default:
                return validationText
            }
        }
    }
    
    /// The length validation scheme performed on the text input, determined by the minimum and
    /// maximum lengths.
    var scheme: LengthValidationScheme {
        if lengthRange.lowerBound == 0 {
            return .max
        } else if lengthRange.lowerBound == lengthRange.upperBound {
            return .exact
        } else {
            return .minAndMax
        }
    }
    
    /// The length validation text, dependent on the length validation scheme.
    var validationText: Text {
        if isNumeric {
            if validationError == .nonInteger {
                return expectedInteger
            } else if  validationError == .nonDecimal {
                return expectedDecimal
            } else {
                return rangeDomain == nil ? Text("") : minAndMaxValue
            }
        } else {
            switch scheme {
            case .max:
                return maximumText
            case .minAndMax:
                return minAndMaxText
            case .exact:
                return exactText
            }
        }
    }
    
    /// Checks for any validation errors and updates the value of `validationError`.
    /// - Parameter text: The text to use for validation.
    /// - Parameter focused: The focus state to use for validation.
    func validate(text: String, focused: Bool) {
        if isNumeric {
            if !isDecimal && !text.isInteger {
                validationError = .nonInteger
            } else if isDecimal && !text.isDecimal {
                validationError = .nonDecimal
            } else if !(rangeDomain?.contains(text) ?? false) {
                validationError = .outOfRange
            } else {
                validationError = nil
            }
        } else if text.count == .zero && isRequired && !focused {
            validationError = .emptyWhenRequired
        } else if !lengthRange.contains(text.count) {
            validationError = .minOrMaxUnmet
        } else {
            validationError = nil
        }
    }
    
    /// Text indicating a field's exact number of allowed characters.
    /// - Note: This is intended to be used in instances where the character minimum and maximum are
    /// identical, such as an ID field.
    var exactText: Text {
        Text(
            "Enter \(lengthRange.lowerBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating the user should enter a field's exact number of required characters."
        )
    }
    
    /// Text indicating a field's value must be convertible to a number.
    var expectedDecimal: Text {
        Text(
            "Value must be a number",
            bundle: .toolkitModule,
            comment: "Text indicating a field's value must be convertible to a number."
        )
    }
    
    /// Text indicating a field's value must be convertible to a whole number.
    var expectedInteger: Text {
        Text(
            "Value must be a whole number",
            bundle: .toolkitModule,
            comment: "Text indicating a field's value must be convertible to a whole number."
        )
    }
    
    /// Text indicating a field's maximum number of allowed characters.
    var maximumText: Text {
        Text(
            "Maximum \(lengthRange.lowerBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating a field's maximum number of allowed characters."
        )
    }
    
    /// Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters.
    var minAndMaxText: Text {
        Text(
            "Enter \(lengthRange.lowerBound) to \(lengthRange.upperBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters."
        )
    }
    
    /// Text indicating a field's number value is not in the correct range of acceptable values.
    var minAndMaxValue: Text {
        let minAndMax = rangeDomain?.displayableMinAndMax
        if let minAndMax {
            return Text(
                "Enter value from \(minAndMax.min) to \(minAndMax.max)",
                bundle: .toolkitModule,
                comment: "Text indicating a field's number value is not in the correct range of acceptable values."
            )
        } else {
            return Text(
                "Enter value in the allowed range",
                bundle: .toolkitModule,
                comment: "Text indicating a field's number value is not in the correct range of acceptable values."
            )
        }
    }
}

private extension String {
    /// A Boolean value indicating that the string contains no alphabetic or special characters and
    /// can be cast to numeric value.
    var isInteger: Bool {
        return Int(self) != nil
    }
    
    /// A Boolean value indicating that the string be cast to decimal value.
    var isDecimal: Bool {
        return Double(self) != nil
    }
}

extension RangeDomain {
    /// String representations of the minimum and maximum value of the range domain.
    var displayableMinAndMax: (min: String, max: String)? {
        if let min = minValue as? Double, let max = maxValue as? Double {
            return (String(min), String(max))
        } else if let min = minValue as? Int, let max = maxValue as? Int {
            return (String(min), String(max))
        } else if let min = minValue as? Int32, let max = maxValue as? Int32 {
            return (String(min), String(max))
        } else {
            return nil
        }
    }
    
    /// Determines if the text's numeric value is within the range domain.
    /// - Parameter value: Text with a numeric value.
    /// - Returns: A Boolean value indicating whether the text's numeric value is within the range domain.
    func contains(_ value: String) -> Bool {
        if let min = minValue as? Double, let max = maxValue as? Double, let v = Double(value) {
            return (min...max).contains(v)
        } else if let min = minValue as? Int, let max = maxValue as? Int, let v = Int(value) {
            return (min...max).contains(v)
        } else if let min = minValue as? Int32, let max = maxValue as? Int32, let v = Int32(value)  {
            return (min...max).contains(v)
        } else {
            return false
        }
    }
}
