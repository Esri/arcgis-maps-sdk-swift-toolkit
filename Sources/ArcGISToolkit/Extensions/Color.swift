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

extension Color {
***REMOVED******REMOVED***/ Initializes a new color with RGB integer values.
***REMOVED******REMOVED***/ - Precondition: `red`, `green` and `blue` are values between 0 and 255 inclusive.
***REMOVED***init(red: Int, green: Int, blue: Int) {
***REMOVED******REMOVED***let validRange = 0...255
***REMOVED******REMOVED***precondition(validRange.contains(red))
***REMOVED******REMOVED***precondition(validRange.contains(green))
***REMOVED******REMOVED***precondition(validRange.contains(blue))
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***red: Double(red)/255,
***REMOVED******REMOVED******REMOVED***green: Double(green)/255,
***REMOVED******REMOVED******REMOVED***blue: Double(blue)/255
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
