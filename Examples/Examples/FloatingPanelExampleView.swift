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
***REMOVED***Toolkit
***REMOVED***

struct FloatingPanelExampleView: View {
***REMOVED***@StateObject private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State var selectedDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED***private let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: initialViewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.floatingPanel(selection: $selectedDetent, isPresented: .constant(true)) {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Preset Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Summary") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .summary
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Half") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .half
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Full") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .full
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Fractional Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("1/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1/4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("1/2") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1/2)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("3/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(3/4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Value Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("200") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(200)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("600") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(600)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
