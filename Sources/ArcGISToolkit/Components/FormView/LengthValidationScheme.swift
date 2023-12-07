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

***REMOVED***/ The type of length validation to be performed.
enum LengthValidationScheme {
***REMOVED******REMOVED***/ A non-zero identical minimum and maximum have been specified.
***REMOVED***case exact
***REMOVED******REMOVED***/ A zero minimum and a non-zero maximum have been specified.
***REMOVED***case max
***REMOVED******REMOVED***/ A non-zero non-identical minimum and maximum have been specified.
***REMOVED***case minAndMax
***REMOVED***
