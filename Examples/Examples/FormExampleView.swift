***REMOVED*** Copyright 2023 Esri.

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
***REMOVED***Toolkit
***REMOVED***

struct FormExampleView: View {
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED******REMOVED***/ The `ArcGISFeature` to edit in the form.
***REMOVED***@State private var feature: ArcGISFeature?
***REMOVED***
***REMOVED******REMOVED***/ The point on the screen the user tapped on to identify a feature.
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***feature = await identifyFeature(with: mapViewProxy)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present a Form in a native SwiftUI sheet
***REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: Binding { feature != nil ***REMOVED*** set: { _ in ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 16.4, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Form(map: map, feature: feature!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.presentationBackground(.thinMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.presentationBackgroundInteraction(.enabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Form(map: map, feature: feature!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Or present a Form in a Floating Panel (provided via the Toolkit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: .constant(.half),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: Binding { feature != nil ***REMOVED*** set: { _ in ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Form(map: map, feature: feature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FormExampleView {
***REMOVED******REMOVED***/ Identifies features, if any, at the current screen point.
***REMOVED******REMOVED***/ - Parameter proxy: The proxy to use for identification.
***REMOVED******REMOVED***/ - Returns: The first identified feature.
***REMOVED***func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
***REMOVED******REMOVED***if let screenPoint = identifyScreenPoint,
***REMOVED******REMOVED***   let feature = try? await Result(awaiting: {
***REMOVED******REMOVED******REMOVED***   try await proxy.identify(
***REMOVED******REMOVED******REMOVED******REMOVED***on: map.operationalLayers.first!,
***REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: screenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED******REMOVED***   )
   ***REMOVED***)
***REMOVED******REMOVED******REMOVED***.cancellationToNil()?
***REMOVED******REMOVED******REMOVED***.get()
***REMOVED******REMOVED******REMOVED***.geoElements
***REMOVED******REMOVED******REMOVED***.first as? ArcGISFeature {
***REMOVED******REMOVED******REMOVED***return feature
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static var sampleData: Self {
***REMOVED******REMOVED***.init(string: <#URL#>)!
***REMOVED***
***REMOVED***
