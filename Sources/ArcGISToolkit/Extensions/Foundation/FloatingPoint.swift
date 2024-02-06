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

import Foundation

extension FloatingPoint {
***REMOVED******REMOVED***/ Returns a value clamped to the given range. If the value is `nan`,
***REMOVED******REMOVED***/ it is clamped to the lower bound of the range.
***REMOVED******REMOVED***/ - Parameter limits: The range of the resultant value.
***REMOVED******REMOVED***/ - Returns: A value clamped to `limits`.
***REMOVED***func clamped(to limits: ClosedRange<Self>) -> Self {
***REMOVED******REMOVED***Self.minimum(
***REMOVED******REMOVED******REMOVED***Self.maximum(self, limits.lowerBound),
***REMOVED******REMOVED******REMOVED***limits.upperBound
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
