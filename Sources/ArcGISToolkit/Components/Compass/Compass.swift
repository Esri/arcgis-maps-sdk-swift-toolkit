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

***REMOVED***/ A Compass (alias North arrow) shows where north is in a MapView or SceneView.
public struct Compass: View {
***REMOVED***@ObservedObject
***REMOVED***public var viewModel: CompassViewModel

***REMOVED******REMOVED***/ Controls the visibility of the compass.
***REMOVED***@State private var opacity = 0.0

***REMOVED***public init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>,
***REMOVED******REMOVED***size: Double = 30.0,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.viewModel = CompassViewModel(
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED***size: size,
***REMOVED******REMOVED******REMOVED***autoHide: autoHide)
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***CompassBody()
***REMOVED******REMOVED******REMOVED***Needle()
***REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: viewModel.viewpoint.adjustedRotation)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.frame(width: viewModel.width, height: viewModel.height)
***REMOVED******REMOVED***.opacity(opacity)
***REMOVED******REMOVED***.onTapGesture { viewModel.resetHeading() ***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewModel.viewpoint) { _ in
***REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(viewModel.hidden ? 0.25 : 0)) {
***REMOVED******REMOVED******REMOVED******REMOVED***opacity = viewModel.hidden ? 0 : 1
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.accessibilityLabel(viewModel.viewpoint.heading)
***REMOVED***
***REMOVED***
