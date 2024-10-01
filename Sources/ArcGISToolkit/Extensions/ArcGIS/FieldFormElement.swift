***REMOVED*** Copyright 2024 Esri
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

extension FieldFormElement {
***REMOVED******REMOVED***/ The coded values of the element's domain.
***REMOVED***var codedValues: [CodedValue] {
***REMOVED******REMOVED***return (domain as? CodedValueDomain)?.codedValues ?? []
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is multiline or not.
***REMOVED***var isMultiline: Bool {
***REMOVED******REMOVED***input is TextAreaFormInput
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Attempts to convert the value to a type suitable for the element's field type and then update
***REMOVED******REMOVED***/ the element with the converted value.
***REMOVED***func convertAndUpdateValue(_ value: String) {
***REMOVED******REMOVED***if fieldType == .text {
***REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED*** else if let fieldType {
***REMOVED******REMOVED******REMOVED***if fieldType.isNumeric && value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(nil)
***REMOVED******REMOVED*** else if fieldType == .int16, let value = Int16(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int32, let value = Int32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int64, let value = Int64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float32, let value = Float32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float64, let value = Float64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
