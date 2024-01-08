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

import SwiftUI
import ArcGIS

extension TextInputFooter {
    /// The length validation text, dependent on the length validation scheme.
    var validationText: Text {
   
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
        if fieldType.isNumeric {
            if !fieldType.isFloatingPoint && !text.isInteger {
                validationError = .nonInteger
            } else if fieldType.isFloatingPoint && !text.isDecimal {
                validationError = .nonDecimal
            } else if !(rangeDomain?.contains(text) ?? false) {
                validationError = .outOfRange
            } else {
                validationError = nil
            }
        } else if text.count == .zero && element.isRequired && !focused {
            validationError = .emptyWhenRequired
        } else if !(lengthRange?.contains(text.count) ?? false) {
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
            "Enter \(lengthRange!.lowerBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating the user should enter a field's exact number of required characters."
        )
    }
    
    /// Text indicating a field's maximum number of allowed characters.
    var maximumText: Text {
        Text(
            "Maximum \(lengthRange!.upperBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating a field's maximum number of allowed characters."
        )
    }
    
    /// Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters.
    var minAndMaxText: Text {
        Text(
            "Enter \(lengthRange!.lowerBound) to \(lengthRange!.upperBound) characters",
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
}
