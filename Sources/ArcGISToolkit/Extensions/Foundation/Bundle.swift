***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation

extension Bundle {
***REMOVED******REMOVED***/ The identifier for the ArcGISToolkit module.
***REMOVED***static var toolkitIdentifier: String { "com.esri.ArcGISToolkit" ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The toolkit module, which is either the resource bundle or the
***REMOVED******REMOVED***/ ArcGISToolkit framework, depending on how the toolkit was built.
***REMOVED***static let toolkitModule = Bundle(identifier: toolkitIdentifier) ?? .module
***REMOVED***
