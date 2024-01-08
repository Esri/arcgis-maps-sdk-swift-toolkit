***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

extension TextInputFooter {
***REMOVED******REMOVED***/ The length validation text, dependent on the length validation scheme.
***REMOVED***var validationText: Text {
   
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***switch scheme {
***REMOVED******REMOVED******REMOVED***case .max:
***REMOVED******REMOVED******REMOVED******REMOVED***return maximumText
***REMOVED******REMOVED******REMOVED***case .minAndMax:
***REMOVED******REMOVED******REMOVED******REMOVED***return minAndMaxText
***REMOVED******REMOVED******REMOVED***case .exact:
***REMOVED******REMOVED******REMOVED******REMOVED***return exactText
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks for any validation errors and updates the value of `validationError`.
***REMOVED******REMOVED***/ - Parameter text: The text to use for validation.
***REMOVED******REMOVED***/ - Parameter focused: The focus state to use for validation.
***REMOVED***func validate(text: String, focused: Bool) {
***REMOVED******REMOVED***if fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED***if !fieldType.isFloatingPoint && !text.isInteger {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .nonInteger
***REMOVED******REMOVED*** else if fieldType.isFloatingPoint && !text.isDecimal {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .nonDecimal
***REMOVED******REMOVED*** else if !(rangeDomain?.contains(text) ?? false) {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .outOfRange
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED******REMOVED***
***REMOVED*** else if text.count == .zero && element.isRequired && !focused {
***REMOVED******REMOVED******REMOVED***validationError = .emptyWhenRequired
***REMOVED*** else if !(lengthRange?.contains(text.count) ?? false) {
***REMOVED******REMOVED******REMOVED***validationError = .minOrMaxUnmet
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field.
***REMOVED***var exactText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of required characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***var maximumText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Maximum \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters.
***REMOVED***var minAndMaxText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) to \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's number value is not in the correct range of acceptable values.
***REMOVED***var minAndMaxValue: Text {
***REMOVED******REMOVED***let minAndMax = rangeDomain?.displayableMinAndMax
***REMOVED******REMOVED***if let minAndMax {
***REMOVED******REMOVED******REMOVED***return Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter value from \(minAndMax.min) to \(minAndMax.max)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's number value is not in the correct range of acceptable values."
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter value in the allowed range",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's number value is not in the correct range of acceptable values."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

extension RangeDomain {
***REMOVED******REMOVED***/ String representations of the minimum and maximum value of the range domain.
***REMOVED***var displayableMinAndMax: (min: String, max: String)? {
***REMOVED******REMOVED***if let min = minValue as? Double, let max = maxValue as? Double {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else if let min = minValue as? Int, let max = maxValue as? Int {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32 {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
