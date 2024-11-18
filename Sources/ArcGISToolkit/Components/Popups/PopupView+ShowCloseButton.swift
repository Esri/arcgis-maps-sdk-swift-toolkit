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

public extension PopupView /* Deprecated */ {
***REMOVED******REMOVED***/ Specifies whether a "close" button should be shown to the right of the popup title. If the "close"
***REMOVED******REMOVED***/ button is shown, you should pass in the `isPresented` argument to the `PopupView`
***REMOVED******REMOVED***/ initializer, so that the the "close" button can close the view.
***REMOVED******REMOVED***/ Defaults to `false`.
***REMOVED******REMOVED***/ - Parameter newShowCloseButton: The new value.
***REMOVED******REMOVED***/ - Returns: A new `PopupView`.
***REMOVED***@available(*, deprecated, message: "Use 'popupHeader(_:)' instead.")
***REMOVED***func showCloseButton(_ newShowCloseButton: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.showCloseButton = newShowCloseButton
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
