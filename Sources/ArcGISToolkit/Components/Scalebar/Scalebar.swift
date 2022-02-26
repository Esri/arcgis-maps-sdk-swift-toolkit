***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ Displays the current scale on-screen
public struct Scalebar: View {
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var scale: Double?

***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Viewpoint?

***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var visibleArea: Polygon?

***REMOVED***public init(
***REMOVED******REMOVED***_ scale: Double?,
***REMOVED******REMOVED***_ viewpoint: Viewpoint?,
***REMOVED******REMOVED***_ visibleArea: Polygon?
***REMOVED***) {
***REMOVED******REMOVED***self.scale = scale
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Text(scale?.description ?? "N/A")
***REMOVED******REMOVED******REMOVED***Text(viewpoint?.targetScale.description ?? "N/A")
***REMOVED******REMOVED******REMOVED***Text(visibleArea?.extent.width.description ?? "N/A")
***REMOVED***
***REMOVED***
***REMOVED***
