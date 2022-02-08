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

***REMOVED***/ Represents the center of the spinning needle at the center of the compass.
struct NeedleCenter: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED***.scale(0.25)
***REMOVED******REMOVED******REMOVED***.foregroundColor(Color.bronze)
***REMOVED***
***REMOVED***

private extension Color {
***REMOVED******REMOVED***/ The bronze color of the center of the compass needle.
***REMOVED***static let bronze = Color(red: 241, green: 169, blue: 59)
***REMOVED***
