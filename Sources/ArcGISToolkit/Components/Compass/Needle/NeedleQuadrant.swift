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

struct NeedleQuadrant: View {
***REMOVED***let color: Color

***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED***let width = geometry.size.width
***REMOVED******REMOVED******REMOVED******REMOVED***let height = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: 0, y: height))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: 0))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: height))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.fill(color)
***REMOVED***
***REMOVED***
***REMOVED***
