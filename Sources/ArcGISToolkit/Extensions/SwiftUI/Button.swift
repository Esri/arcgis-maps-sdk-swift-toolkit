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

extension Button<Text> {
***REMOVED******REMOVED***/ Returns a button with the title "Cancel" and the given action.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the user triggers the
***REMOVED******REMOVED***/ button.
***REMOVED******REMOVED***/ - Returns: A button.
***REMOVED***static nonisolated func cancel(action: @escaping @MainActor () -> Void) -> Self {
***REMOVED******REMOVED***Button(role: .cancel, action: action) {
***REMOVED******REMOVED******REMOVED***Text(LocalizedStringResource.cancel)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a button with the title "Done" and the given action.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the user triggers the
***REMOVED******REMOVED***/ button.
***REMOVED******REMOVED***/ - Returns: A button.
***REMOVED***static nonisolated func done(action: @escaping @MainActor () -> Void) -> Self {
***REMOVED******REMOVED***Button(action: action) {
***REMOVED******REMOVED******REMOVED***Text.done
***REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a button with the title "ok" and the given action.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the user triggers the
***REMOVED******REMOVED***/ button.
***REMOVED******REMOVED***/ - Returns: A button.
***REMOVED***static nonisolated func ok(action: @escaping @MainActor () -> Void) -> Self {
***REMOVED******REMOVED***Button(action: action) {
***REMOVED******REMOVED******REMOVED***Text(LocalizedStringResource.ok)
***REMOVED***
***REMOVED***
***REMOVED***
