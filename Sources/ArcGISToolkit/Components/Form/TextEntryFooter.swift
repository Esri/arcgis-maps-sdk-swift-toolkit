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
    /// <#Description#>
    @State private var validationError: LengthError? = nil
    
    /// The current length of the text in the text entry field.
    let currentLength: Int
    
    /// A Boolean value indicating whether the text entry field is focused.
    let isFocused: Bool
    
    /// The description of the text entry field.
    let description: String
    
    /// A Boolean value indicating whether the text entry field is required.
    let isRequired: Bool
    
    /// The maximum allowable length of text in the text entry field.
    let maxLength: Int
    
    /// /// The minimum allowable length of text in the text entry field.
    let minLength: Int
    
    var body: some View {
        HStack(alignment: .top) {
            if let validationError {
                switch validationError {
                case .emptyWhenRequired:
                    requiredText
                case .tooLong:
                    maximumText
                case .tooShort:
                    minimumText
                }
            } else if !description.isEmpty {
                Text(description)
            } else if description.isEmpty && isFocused {
                maximumText
            }
            Spacer()
            if isFocused {
                Text(currentLength, format: .number)
            }
        }
        .font(.footnote)
        .foregroundColor(validationError == nil ? .secondary : .red)
        .onChange(of: currentLength) { newLength in
            validate(length: newLength, focused: isFocused)
        }
        .onChange(of: isFocused) { newFocus in
            validate(length: currentLength, focused: newFocus)
        }
    }
}

extension TextEntryFooter {
    /// Checks for any validation errors and updates the value of `validationError`.
    /// - Parameter length: The length of text to use for validation.
    /// - Parameter focused: The focus state to use for validation.
    func validate(length: Int, focused: Bool) {
        if length == .zero && isRequired && !focused {
            validationError = .emptyWhenRequired
        } else if length < minLength {
            validationError = .tooShort
        } else if length > maxLength {
            validationError = .tooLong
        } else {
            validationError = nil
        }
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
    var minimumText: Text {
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
