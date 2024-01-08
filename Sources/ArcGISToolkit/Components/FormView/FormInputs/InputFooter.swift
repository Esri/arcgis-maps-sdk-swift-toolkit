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

/// A view shown at the bottom of a field element in a form.
struct InputFooter: View {
    /// The view model for the form.
    @EnvironmentObject var model: FormViewModel
    
    /// The form element the footer belongs to.
    let element: FieldFormElement
    
    var body: some View {
        HStack(alignment: .top) {
            Group {
                if isShowingError {
                    errorMessage
                } else {
                    Text(element.description)
                }
            }
            .accessibilityIdentifier("\(element.label) Footer")
            Spacer()
            if isFocused, element.fieldType == .text, element.description.isEmpty || firstError != nil {
                Text(element.formattedValue.count, format: .number)
                    .accessibilityIdentifier("\(element.label) Character Indicator")
            }
        }
        .font(.footnote)
        .foregroundColor(isShowingError ? .red : .secondary)
    }
}

extension InputFooter {
    var errorMessage: Text? {
        guard let error = firstError else { return nil }
        return switch error {
        case .featureFormNullNotAllowedError:
            Text(
                "Value must not be empty",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must not be empty."
            )
        case .featureFormExceedsMaximumDateTimeError:
            Text("Unhandled Error")
        case .featureFormLessThanMinimumDateTimeError:
            Text("Unhandled Error")
        case .featureFormExceedsMaximumLengthError:
            Text("Unhandled Error")
        case .featureFormLessThanMinimumLengthError:
            Text("Unhandled Error")
        case .featureFormExceedsNumericMaximumError:
            Text("Unhandled Error")
        case .featureFormLessThanNumericMinimumError:
            Text("Unhandled Error")
        case .featureFormNotInCodedValueDomainError:
            Text(
                "Value must be within domain",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must exist in the domain."
            )
        case .featureFormFieldIsRequiredError:
            Text.required
        case .featureFormIncorrectValueTypeError:
            if element.fieldType?.isFloatingPoint ?? false {
                Text(
                    "Value must be a number",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be convertible to a number."
                )
                
            } else if element.fieldType?.isNumeric ?? false {
                Text(
                    "Value must be a whole number",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be convertible to a whole number."
                )
            } else {
                Text(
                    "Value must be of correct type",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be of the correct type."
                )
            }
        }
    }
    
    var firstError: ArcGIS.FeatureFormError? {
        model.validationErrors[element.fieldName]?.first as? ArcGIS.FeatureFormError
    }
    
    var isFocused: Bool {
        model.focusedElement == element
    }
    
    var lengthRange: ClosedRange<Int>? {
        if let input = element.input as? TextAreaFormInput {
            return input.minLength...input.maxLength
        } else if let input = element.input as? TextBoxFormInput, element.fieldType == .text {
            return input.minLength...input.maxLength
        } else {
            return nil
        }
    }
    
    /// The length validation scheme performed on the text input, determined by the minimum and
    /// maximum lengths.
    var lengthValidationScheme: LengthValidationScheme {
        if lengthRange?.lowerBound == 0 {
            return .max
        } else if lengthRange?.lowerBound == lengthRange?.upperBound {
            return .exact
        } else {
            return .minAndMax
        }
    }
    
    var numericRange: RangeDomain? {
        element.domain as? RangeDomain
    }
    
    var isShowingError: Bool {
        element.isEditable && firstError != nil
    }
}
