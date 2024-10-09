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
@MainActor
struct InputFooter: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The validation error visibility configuration of a form.
    @Environment(\.validationErrorVisibility) private var validationErrorVisibility
    
    /// The view model for the form.
    @EnvironmentObject var model: FormViewModel
    
    /// An ID regenerated each time the element's value changes.
    ///
    /// Allows the footer to be recomputed to reflect changes in validation errors or input length.
    @State private var id = UUID()
    
    /// The element the input belongs to.
    let element: FieldFormElement
    
    var body: some View {
        HStack(alignment: .top) {
            Group {
                if isShowingError {
                    errorMessage
                } else if !element.description.isEmpty {
                    Text(element.description)
                } else if model.focusedElement == element {
                    if element.fieldType == .text, let lengthRange {
                        if lengthRange.lowerBound == lengthRange.upperBound {
                            makeExactLengthMessage(lengthRange)
                        } else if lengthRange.lowerBound > .zero {
                            makeLengthRangeMessage(lengthRange)
                        } else {
                            makeMaximumLengthMessage(lengthRange)
                        }
                    } else if element.fieldType?.isNumeric ?? false, let numericRange {
                        makeNumericRangeMessage(numericRange)
                    }
                }
            }
            .accessibilityIdentifier("\(element.label) Footer")
            Spacer()
            if isShowingCharacterIndicator {
                Text(element.formattedValue.count, format: .number)
                    .accessibilityIdentifier("\(element.label) Character Indicator")
            }
        }
        .font(.footnote)
        .foregroundColor(isShowingError ? .red : .secondary)
        .id(id)
        .padding(.vertical, elementPadding / 2)
        .task {
            for await _ in element.$value {
                id = UUID()
            }
        }
    }
}

extension InputFooter {
    /// Localized error text to be shown to a user depending on the type of error information available.
    var errorMessage: Text? {
        guard let error = primaryError else { return nil }
        return switch error {
        case .nullNotAllowed:
            Text(
                "Value must not be empty",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must not be empty."
            )
        case .exceedsMaximumDateTime:
            if let input = element.input as? DateTimePickerFormInput, let max = input.max {
                Text(
                    "Date must be on or before \(max, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be on or before the maximum date specified in the variable."
                )
            } else {
                Text(
                    "Date exceeds maximum",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must not exceed a maximum date."
                )
            }
        case .lessThanMinimumDateTime:
            if let input = element.input as? DateTimePickerFormInput, let min = input.min {
                Text(
                    "Date must be on or after \(min, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be on or after the minimum date specified in the variable."
                )
            } else {
                Text(
                    "Date less than minimum",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must meet a minimum date."
                )
            }
        case .exceedsMaximumLength:
            if let lengthRange {
                if lengthRange.lowerBound == lengthRange.upperBound {
                    makeExactLengthMessage(lengthRange)
                } else {
                    makeMaximumLengthMessage(lengthRange)
                }
            } else {
                Text(
                    "Maximum character length exceeded",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's maximum number of allowed characters is exceeded."
                )
            }
        case .lessThanMinimumLength:
            if let lengthRange {
                if lengthRange.lowerBound == lengthRange.upperBound {
                    makeExactLengthMessage(lengthRange)
                } else {
                    makeLengthRangeMessage(lengthRange)
                }
            } else {
                Text(
                    "Minimum character length not met",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's minimum number of allowed characters is not met."
                )
            }
        case .exceedsNumericMaximum:
            if let numericRange {
                makeNumericRangeMessage(numericRange)
            } else {
                Text(
                    "Exceeds maximum value",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value exceeds the maximum allowed value."
                )
            }
        case .lessThanNumericMinimum:
            if let numericRange {
                makeNumericRangeMessage(numericRange)
            } else {
                Text(
                    "Less than minimum value",
                    bundle: .toolkitModule,
                    comment: "Text indicating a field's value must be within the allowed range."
                )
            }
        case .notInCodedValueDomain:
            Text(
                "Value must be within domain",
                bundle: .toolkitModule,
                comment: "Text indicating a field's value must exist in the domain."
            )
        case .fieldIsRequired:
            Text.required
        case .incorrectValueType:
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
        @unknown default:
            Text(
                "Unknown validation error",
                bundle: .toolkitModule,
                comment: "Text indicating a field has an unknown validation error."
            )
        }
    }
    
    /// A Boolean value which indicates whether or not the character indicator is showing in the footer.
    var isShowingCharacterIndicator: Bool {
        model.focusedElement == element
        && !(element.fieldType?.isNumeric ?? false)
        && (element.input is TextAreaFormInput || element.input is TextBoxFormInput)
        && (element.description.isEmpty || primaryError != nil)
    }
    
    /// A Boolean value which indicates whether or not an error is showing in the footer.
    var isShowingError: Bool {
        (element.isEditable || element.hasValueExpression)
        && primaryError != nil
        && (model.previouslyFocusedElements.contains(element) || validationErrorVisibility == .visible || element.hasValueExpression)
    }
    
    /// The allowable number of characters in the input.
    var lengthRange: ClosedRange<Int>? {
        if let input = element.input as? TextAreaFormInput {
            return input.minLength...input.maxLength
        } else if element.fieldType == .text {
            if let input = element.input as? TextBoxFormInput {
                return input.minLength...input.maxLength
            } else if let input = element.input as? BarcodeScannerFormInput {
                return input.minLength...input.maxLength
            }
        }
        return nil
    }
    
    /// The allowable numeric range the input.
    var numericRange: (min: String, max: String)? {
        if let rangeDomain = element.domain as? RangeDomain, let minMax = rangeDomain.displayableMinAndMax {
            return minMax
        } else {
            return nil
        }
    }
    
    /// The error to display for the input. If the element is not focused and has a required error this will be
    /// the primary error. Otherwise the primary error is the first error in the element's set of errors.
    var primaryError: ArcGIS.FeatureFormError? {
        let elementErrors = element.validationErrors as? [ArcGIS.FeatureFormError]
        if let requiredError = elementErrors?.first(where: {
            switch $0 {
            case .fieldIsRequired(_):
                return true
            default:
                return false
            }
        }), model.focusedElement != element {
            return requiredError
        } else {
            return elementErrors?.first(where: {
                switch $0 {
                case .fieldIsRequired(_):
                    return false
                default:
                    return true
                }
            })
        }
    }
    
    /// Text indicating a field's exact number of allowed characters.
    /// - Note: This is intended to be used in instances where the character minimum and maximum are
    /// identical, such as an ID field.
    func makeExactLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
        if element.hasValueExpression {
            Text(
                "Value must be ^[\(lengthRange.lowerBound) characters](inflect: true)",
                bundle: .toolkitModule,
                comment: "Text indicating a field's computed value must be an exact number of characters."
            )
        } else {
            Text(
                "Enter ^[\(lengthRange.lowerBound) characters](inflect: true)",
                bundle: .toolkitModule,
                comment: "Text indicating the user should enter a field's exact number of characters."
            )
        }
    }
    
    /// Text indicating a field's value must be within the allowed length range.
    func makeLengthRangeMessage(_ lengthRange: ClosedRange<Int>) -> Text {
        if element.hasValueExpression {
            Text(
                "Value must be \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
                bundle: .toolkitModule,
                comment: """
                         Text indicating a field's computed value must be within the
                         allowed length range. The first and second parameter
                         hold the minimum and maximum length respectively.
                         """
            )
        } else {
            Text(
                "Enter \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
                bundle: .toolkitModule,
                comment: """
                         Text indicating a field's value must be within the
                         allowed length range. The first and second parameter
                         hold the minimum and maximum length respectively.
                         """
            )
        }
    }
    
    /// Text indicating a field's maximum number of allowed characters.
    func makeMaximumLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
        Text(
            "Maximum ^[\(lengthRange.upperBound) characters](inflect: true)",
            bundle: .toolkitModule,
            comment: "Text indicating a field's maximum number of allowed characters."
        )
    }
    
    /// Text indicating a field's value must be within the allowed numeric range.
    func makeNumericRangeMessage(_ numericRange: (min: String, max: String)) -> Text {
        if element.hasValueExpression {
            Text(
                "Value must be from \(numericRange.min) to \(numericRange.max)",
                bundle: .toolkitModule,
                comment: """
                         Text indicating a field's computed value must be within the allowed range.
                         The first and second parameter hold the minimum and maximum values respectively.
                         """
            )
        } else {
            Text(
                "Enter value from \(numericRange.min) to \(numericRange.max)",
                bundle: .toolkitModule,
                comment: """
                         Text indicating a field's value must be within the allowed range.
                         The first and second parameter hold the minimum and maximum values respectively.
                         """
            )
        }
    }
}

private extension RangeDomain {
    /// String representations of the minimum and maximum value of the range domain.
    var displayableMinAndMax: (min: String, max: String)? {
        if let min = minValue as? Double, let max = maxValue as? Double {
            return (min.formatted(.number.precision(.fractionLength(1...))), max.formatted(.number.precision(.fractionLength(1...))))
        } else if let min = minValue as? Int, let max = maxValue as? Int {
            return (min.formatted(), max.formatted())
        } else if let min = minValue as? Int32, let max = maxValue as? Int32 {
            return (min.formatted(), max.formatted())
        } else {
            return nil
        }
    }
}
