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
            if model.focusedElement == element, element.fieldType == .text, element.description.isEmpty || primaryError != nil {
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
        guard let error = primaryError else { return nil }
        return switch error {
        case .featureFormNullNotAllowedError:
            Text(
                "Value must not be empty",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must not be empty."
            )
        case .featureFormExceedsMaximumDateTimeError:
            Text(
                "Date exceeds maximum",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must not exceed a maximum date."
            )
        case .featureFormLessThanMinimumDateTimeError:
            Text(
                "Date does not meet minimum",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must meet a minimum date."
            )
        case .featureFormExceedsMaximumLengthError:
            if lengthRange?.lowerBound == lengthRange?.upperBound {
                exactLengthMessage
            } else {
                Text(
                    "Maximum \(lengthRange!.upperBound) characters",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's maximum number of allowed characters."
                )
            }
        case .featureFormLessThanMinimumLengthError:
            if lengthRange?.lowerBound == lengthRange?.upperBound {
                exactLengthMessage
            } else {
                Text(
                    "Minimum \(lengthRange!.lowerBound) characters",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's minimum number of allowed characters."
                )
            }
        case .featureFormExceedsNumericMaximumError, .featureFormLessThanNumericMinimumError:
            if let numericRange = element.domain as? RangeDomain, let minMax = numericRange.displayableMinAndMax {
                Text(
                    "Enter value from \(minMax.min) to \(minMax.max)",
                    bundle: .toolkitModule,
                    comment: """
                             Text indicating a field's value must be within the allowed range.
                             The first and second parameter hold the minimum and maximum values respectively.
                             """
                )
            } else {
                Text(
                    "Value must be within allowed range",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be within the allowed range."
                )
            }
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
    
    /// Text indicating a field's exact number of allowed characters.
    /// - Note: This is intended to be used in instances where the character minimum and maximum are
    /// identical, such as an ID field.
    var exactLengthMessage: Text {
        Text(
            "Enter \(lengthRange!.lowerBound) characters",
            bundle: .toolkitModule,
            comment: "Text indicating the user should enter a field's exact number of required characters."
        )
    }
    
    /// The error to display for the input. If the element is not focused and has a required error this will be
    /// the primary error. Otherwise the primary error is the first error in the element's set of errors.
    var primaryError: ArcGIS.FeatureFormError? {
        let elementErrors = model.validationErrors[element.fieldName] as? [ArcGIS.FeatureFormError]
        if let requiredError = elementErrors?.first(where: { $0 == .featureFormFieldIsRequiredError }), model.focusedElement != element {
            return requiredError
        } else {
            return elementErrors?.first(where: { $0 != .featureFormFieldIsRequiredError })
        }
    }
    
    /// The alloable range of number of characters in the input.
    var lengthRange: ClosedRange<Int>? {
        if let input = element.input as? TextAreaFormInput {
            return input.minLength...input.maxLength
        } else if let input = element.input as? TextBoxFormInput, element.fieldType == .text {
            return input.minLength...input.maxLength
        } else {
            return nil
        }
    }
    
    /// Determines whether an error is showing in the footer.
    var isShowingError: Bool {
        element.isEditable && primaryError != nil && model.previouslyFocusedFields.contains(element)
    }
}

private extension RangeDomain {
    /// String representations of the minimum and maximum value of the range domain.
    var displayableMinAndMax: (min: String, max: String)? {
        if let min = minValue as? Double, let max = maxValue as? Double {
            return (min.formatted(), max.formatted())
        } else if let min = minValue as? Int, let max = maxValue as? Int {
            return (min.formatted(), max.formatted())
        } else if let min = minValue as? Int32, let max = maxValue as? Int32 {
            return (min.formatted(), max.formatted())
        } else {
            return nil
        }
    }
}
