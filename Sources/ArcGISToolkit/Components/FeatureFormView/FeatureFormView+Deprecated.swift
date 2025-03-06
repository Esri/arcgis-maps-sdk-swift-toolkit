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

public extension FeatureFormView /* Deprecated */ {
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.7.
***REMOVED***@available(*, deprecated, message: "Use init(featureForm:) instead.")
***REMOVED***init(featureForm: FeatureForm) {
***REMOVED******REMOVED***self.init(featureForm: .constant(featureForm))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of a form.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.7.
***REMOVED***@available(*, deprecated)
***REMOVED***enum ValidationErrorVisibility: Sendable {
***REMOVED******REMOVED******REMOVED***/ Errors may be visible or hidden for a given form field depending on its focus state.
***REMOVED******REMOVED***case automatic
***REMOVED******REMOVED******REMOVED***/ Errors will always be visible for a given form field.
***REMOVED******REMOVED***case visible
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies the visibility of validation errors in the form.
***REMOVED******REMOVED***/ - Parameter visibility: The preferred visibility of validation errors in the form.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.7. ``FeatureFormView`` automatically manages
***REMOVED******REMOVED***/ validation error visibility.
***REMOVED***@available(*, deprecated)
***REMOVED***func validationErrors(_ visibility: ValidationErrorVisibility) -> Self {
***REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
