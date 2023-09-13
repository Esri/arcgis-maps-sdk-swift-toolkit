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
    /// An error that is present when a length constraint is not met.
    @State private var validationError: LengthError?
    
    /// A Boolean value indicating whether the text input field has previously satisfied the minimum
    /// length at any point in time.
    @State private var hasPreviouslySatisfiedMinimum: Bool
    
    /// The current length of the text in the text input field.
    private let currentLength: Int
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// A Boolean value indicating whether the text input field is focused.
    private let isFocused: Bool
    
    /// The description of the text input field.
    private let description: String
    
    /// A Boolean value indicating whether the text input field is required.
    private let isRequired: Bool
    
    /// The maximum allowable length of text in the text input field.
    private let maxLength: Int
    
    /// The minimum allowable length of text in the text input field.
    private let minLength: Int
    
    /// Creates a footer shown at the bottom of each text input element in a form.
    /// - Parameters:
    ///   - currentLength: The current length of the text in the text input field.
    ///   - isFocused: A Boolean value indicating whether the text input field is focused.
    ///   - element: A field element that provides a description for the text input and whether
    ///  or not text is required for this input.
    ///   - input: A form input that provides length constraints for the text input.
    init(
        currentLength: Int,
        isFocused: Bool,
        element: FieldFormElement,
        input: FormInput
    ) {
        self.currentLength = currentLength
        self.element = element
        self.isFocused = isFocused
        self.description = element.description
        //TODO: add `required` property to API
        self.isRequired = false//element.required
        
        switch input {
        case let input as TextBoxFormInput:
            self.maxLength = input.maxLength
            self.minLength = input.minLength
            _hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
        case let input as TextAreaFormInput:
            self.maxLength = input.maxLength
            self.minLength = input.minLength
            _hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
        default:
            fatalError("TextInputFooter can only be used with TextAreaFormInput or TextBoxFormInput")
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if let primaryMessage {
                primaryMessage
                    .accessibilityIdentifier("\(element.label) Footer")
            }
            Spacer()
            if isFocused, description.isEmpty || validationError != nil {
                Text(currentLength, format: .number)
                    .accessibilityIdentifier("\(element.label) Character Indicator")
            }
        }
        .font(.footnote)
        .foregroundColor(validationError == nil ? .secondary : .red)
        .onChange(of: currentLength) { newLength in
            if !hasPreviouslySatisfiedMinimum {
                if newLength >= minLength {
                    hasPreviouslySatisfiedMinimum = true
                }
            } else {
                validate(length: newLength, focused: isFocused)
            }
        }
        .onChange(of: isFocused) { newIsFocused in
            if hasPreviouslySatisfiedMinimum || !newIsFocused {
                validate(length: currentLength, focused: newIsFocused)
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
        case (.some(let lengthError), _, _):
            switch (lengthError, scheme) {
            case (.emptyWhenRequired, .max):
                return requiredText
            default:
                return validationText
            }
        }
    }
    
    /// The length validation scheme performed on the text input, determined by the minimum and
    /// maximum lengths.
    var scheme: LengthValidationScheme {
        if minLength == 0 {
            return .max
        } else if minLength == maxLength {
            return .exact
        } else {
            return .minAndMax
        }
    }
    
    /// The length validation text, dependent on the length validation scheme.
    var validationText: Text {
        switch scheme {
        case .max:
            return maximumText
        case .minAndMax:
            return minAndMaxText
        case .exact:
            return exactText
        }
    }
    
    /// Checks for any validation errors and updates the value of `validationError`.
    /// - Parameter length: The length of text to use for validation.
    /// - Parameter focused: The focus state to use for validation.
    func validate(length: Int, focused: Bool) {
        if length == .zero && isRequired && !focused {
            validationError = .emptyWhenRequired
        } else if length < minLength || length > maxLength {
            validationError = .minOrMaxUnmet
        } else {
            validationError = nil
        }
    }
    
    /// Text indicating a field's exact number of allowed characters.
    /// - Note: This is intended to be used in instances where the character minimum and maximum are
    /// identical, such as an ID field; the implementation uses `minLength` but it could just as
    /// well use `maxLength`.
    var exactText: Text {
        Text(
            "Enter \(minLength) characters",
            bundle: .toolkitModule,
            comment: "Text indicating a field's exact number of required characters."
        )
    }
    
    /// Text indicating a field's maximum number of allowed characters.
    var maximumText: Text {
        Text(
            "Maximum \(maxLength) characters",
            bundle: .toolkitModule,
            comment: "Text indicating a field's maximum number of allowed characters."
        )
    }
    
    /// Text indicating a field's minimum and maximum number of allowed characters.
    var minAndMaxText: Text {
        Text(
            "Enter \(minLength) to \(maxLength) characters",
            bundle: .toolkitModule,
            comment: "Text indicating a field's minimum and maximum number of allowed characters."
        )
    }
    
    /// Text indicating a field is required.
    var requiredText: Text {
        Text(
            "Required",
            bundle: .toolkitModule,
            comment: "Text indicating a field is required"
        )
    }
}
