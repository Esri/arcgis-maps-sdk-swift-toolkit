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

***REMOVED***/ An error that can be encountered while performing text validation.
enum TextValidationError {
***REMOVED******REMOVED***/ The text field was left empty but a value is required.
***REMOVED***case emptyWhenRequired
***REMOVED******REMOVED***/ The text field has too few or too many characters.
***REMOVED***case minOrMaxUnmet
***REMOVED******REMOVED***/ The text field contains a value that does not represent a whole number.
***REMOVED***case nonInteger
***REMOVED******REMOVED***/ The text field contains a value that does not represent a fractional number.
***REMOVED***case nonDecimal
***REMOVED******REMOVED***/ The text number value is out of range.
***REMOVED***case outOfRange
***REMOVED***
