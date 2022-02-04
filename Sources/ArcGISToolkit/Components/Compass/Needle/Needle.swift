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

struct Needle: View {
***REMOVED***private let grayDark = Color(red: 128, green: 128, blue: 128)

***REMOVED***private let grayLight = Color(red: 169, green: 168, blue: 168)

***REMOVED***private let redDark = Color(red: 124, green: 22, blue: 13)

***REMOVED***private let redLight = Color(red: 233, green: 51, blue: 35)

***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: redLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: redDark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: grayLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: grayDark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***NeedleCenter()
***REMOVED***
***REMOVED******REMOVED***.aspectRatio(1.0/3.0, contentMode: .fit)
***REMOVED******REMOVED***.scaleEffect(0.6)
***REMOVED***
***REMOVED***
