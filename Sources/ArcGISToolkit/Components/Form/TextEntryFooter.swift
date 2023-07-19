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

import FormsPlugin
import SwiftUI

/// A view shown at the bottom of each text entry element in a form.
struct TextEntryFooter: View {
    /// An error that is present when a length constraint is not met.
    @State private var validationError: LengthError?
    
    /// A Boolean value indicating whether the text entry field has previously satisfied the minimum
    /// length at any point in time.
    @State private var hasPreviouslySatisfiedMinimum: Bool
    
    /// The current length of the text in the text entry field.
    private let currentLength: Int
    
    /// A Boolean value indicating whether the text entry field is focused.
    private let isFocused: Bool
    
    /// The description of the text entry field.
    private let description: String
    
    /// A Boolean value indicating whether the text entry field is required.
    private let isRequired: Bool
    
    /// The maximum allowable length of text in the text entry field.
    private let maxLength: Int
    
    /// The minimum allowable length of text in the text entry field.
    private let minLength: Int
    
    /// Creates a footer shown at the bottom of each text entry element in a form.
    /// - Parameters:
    ///   - currentLength: The current length of the text in the text entry field.
    ///   - isFocused: A Boolean value indicating whether the text entry field is focused.
    ///   - element: A field element that provides a description for the text entry and whether
    ///  or not text is required for this entry.
    ///   - input: A form input that provides length constraints for the text entry.
    init(
        currentLength: Int,
        isFocused: Bool,
        element: FieldFeatureFormElement,
        input: FeatureFormInput
    ) {
        self.currentLength = currentLength
        self.isFocused = isFocused
        self.description = element.description ?? ""
        self.isRequired = element.required
        
        switch input {
        case let input as TextBoxFeatureFormInput:
            self.maxLength = input.maxLength
            self.minLength = input.minLength
            _hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
        case let input as TextAreaFeatureFormInput:
            self.maxLength = input.maxLength
            self.minLength = input.minLength
            _hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
        default:
            fatalError("TextEntryFooter can only be used with TextAreaFeatureFormInput or TextBoxFeatureFormInput")
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if let primaryMessage {
                primaryMessage
            }
            Spacer()
            if isFocused, description.isEmpty || validationError != nil {
                Text(currentLength, format: .number)
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

extension TextEntryFooter {
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
    
    /// The length validation scheme performed on the text entry, determined by the minimum and
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
