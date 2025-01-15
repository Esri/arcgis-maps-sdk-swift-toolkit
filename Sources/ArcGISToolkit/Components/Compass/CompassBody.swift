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

***REMOVED***/ Represents the circular housing which encompasses the spinning needle at the center of the compass.
struct CompassBody: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***let borderWidth = geometry.size.width * 0.025
***REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED***.inset(by: borderWidth / 2.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(lineWidth: borderWidth)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.outline)
***REMOVED******REMOVED******REMOVED******REMOVED***.background {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.fill)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension Color {
***REMOVED******REMOVED***/ The background color of the compass housing.
***REMOVED***static let fill = Color(red: 228, green: 240, blue: 244)
***REMOVED***
***REMOVED******REMOVED***/ The outline color of the compass housing.
***REMOVED***static let outline = Color(red: 127, green: 127, blue: 127)
***REMOVED***
