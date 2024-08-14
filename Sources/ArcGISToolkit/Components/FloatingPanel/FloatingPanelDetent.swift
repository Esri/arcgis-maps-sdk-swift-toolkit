***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ A value that represents a height where a sheet naturally rests.
public enum FloatingPanelDetent: Equatable, Sendable {
***REMOVED******REMOVED***/ A height based upon a fraction of the maximum height.
***REMOVED***case fraction(_ fraction: CGFloat)
***REMOVED******REMOVED***/ The maximum height.
***REMOVED***case full
***REMOVED******REMOVED***/ Half of the maximum height.
***REMOVED***case half
***REMOVED******REMOVED***/ A height based upon a fixed value.
***REMOVED***case height(_ height: CGFloat)
***REMOVED******REMOVED***/ A height large enough to display a short summary.
***REMOVED***case summary
***REMOVED***
