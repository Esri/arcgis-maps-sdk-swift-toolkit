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

***REMOVED***/ A Boolean value that indicates whether to display all form validation errors.
private struct ForceValidation: EnvironmentKey {
***REMOVED***static let defaultValue: Bool = false
***REMOVED***

extension EnvironmentValues {
***REMOVED******REMOVED***/ A Boolean value that indicates whether to display all form validation errors.
***REMOVED***var forceValidation: Bool {
***REMOVED******REMOVED***get { self[ForceValidation.self] ***REMOVED***
***REMOVED******REMOVED***set { self[ForceValidation.self] = newValue ***REMOVED***
***REMOVED***
***REMOVED***
