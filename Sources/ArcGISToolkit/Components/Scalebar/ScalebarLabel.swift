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

***REMOVED***

***REMOVED***/ Models a label displayed along the edge of a scalebar
@available(visionOS, unavailable)
struct ScalebarLabel {
***REMOVED******REMOVED***/ The number of the label with the leftmost label ("0") starting at -1.
***REMOVED***let index: Int
***REMOVED***
***REMOVED******REMOVED***/ The horizontal offset of this label.
***REMOVED***let xOffset: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The text to be displayed by this label.
***REMOVED***let text: String
***REMOVED***
***REMOVED******REMOVED***/ The vertical offset of this label.
***REMOVED***static var yOffset: CGFloat {
***REMOVED******REMOVED***return Scalebar.fontHeight / 2.0
***REMOVED***
***REMOVED***
