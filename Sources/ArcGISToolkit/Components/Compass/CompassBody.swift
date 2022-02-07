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

***REMOVED***/ Represents the circular housing which encompasses the spinning needle at the center of the compass.
struct CompassBody: View {
***REMOVED******REMOVED***/ The background color of the compass housing.
***REMOVED***private let fill = Color(red: 228, green: 240, blue: 244)

***REMOVED******REMOVED***/ The outline color of the compass housing.
***REMOVED***private let outline = Color(red: 127, green: 127, blue: 127)

***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***let borderWidth = geometry.size.width * 0.025
***REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED***.inset(by: borderWidth / 2.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(lineWidth: borderWidth)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(outline)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Circle().foregroundColor(fill))
***REMOVED***
***REMOVED***
***REMOVED***
