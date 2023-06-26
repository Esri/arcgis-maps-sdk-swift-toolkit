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
    
    /// <#Description#>
    let currentLength: Int
    
    /// <#Description#>
    let isFocused: Bool
    
    /// <#Description#>
    let description: String
    
    /// <#Description#>
    let isRequired: Bool
    
    /// <#Description#>
    let maxLength: Int
    
    /// <#Description#>
    let minLength: Int
    
    var body: some View {
        HStack {
            if !description.isEmpty {
                Text(description)
            }
            Spacer()
            if isFocused {
                Text(currentLength, format: .number)
            }
        }
        .font(.footnote)
        .foregroundColor(validationError == nil ? .secondary : .red)
        .onChange(of: currentLength) { _ in validateLength() }
        .onChange(of: isFocused) { _ in validateLength() }
    }
}

extension TextEntryFooter {
    /// <#Description#>
    func validateLength() {
        if currentLength == .zero && isRequired {
            validationError = .emptyWhenRequired
        } else if currentLength < minLength {
            validationError = .tooShort
        } else if currentLength > maxLength {
            validationError = .tooLong
        } else {
            validationError = nil
        }
    }
}

/// <#Description#>
enum LengthError {
    case emptyWhenRequired
    case tooLong
    case tooShort
}
