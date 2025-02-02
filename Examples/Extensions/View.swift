***REMOVED*** Copyright 2025 Esri
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

extension View {
***REMOVED******REMOVED***/ Performs an action when a specified value changes.
***REMOVED******REMOVED***/ - Note: This is temporary until our minumum platform versions are increased.
***REMOVED******REMOVED***/ Without this a warning will show saying we are using a deprecated `onChange(of:perform:)` method.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - value: The value to check when determining whether to run the
***REMOVED******REMOVED***/***REMOVED*** closure.
***REMOVED******REMOVED***/   - action: A closure to run when the value changes. The closure
***REMOVED******REMOVED***/***REMOVED*** takes a `newValue` parameter that indicates the updated
***REMOVED******REMOVED***/***REMOVED*** value.
***REMOVED******REMOVED***/ - Returns: A view that runs an action when the specified value changes.
***REMOVED***func onChange<V>(
***REMOVED******REMOVED***_ value: V,
***REMOVED******REMOVED***perform action: @escaping (_ newValue: V) -> Void
***REMOVED***) -> some View where V: Equatable {
***REMOVED******REMOVED***if #available(iOS 17.0, macCatalyst 17.0, visionOS 1.0, *) {
***REMOVED******REMOVED******REMOVED***return onChange(of: value) { _, newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***action(newValue)
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return onChange(of: value) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***action(newValue)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
