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

struct FormsExampleView: View {
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let feature = try await mapViewProxy.identify(on: map.operationalLayers.first!, screenPoint: screenPoint, tolerance: 10).geoElements.first as? ArcGISFeature else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(selectedDetent: .constant(.half), horizontalAlignment: .leading, isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Forms(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED***
***REMOVED***
***REMOVED***

extension URL {
***REMOVED***static var sampleData: Self {
***REMOVED******REMOVED***.init(string: "<#URL#>")!
***REMOVED***
***REMOVED***
