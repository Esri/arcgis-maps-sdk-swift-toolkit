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
***REMOVED******REMOVED***/ The data model containing the `Map` displayed in the `MapView`.
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The Floating Panel's current content.
***REMOVED***@State private var demoContent: FloatingPanelDemoContent?
***REMOVED***
***REMOVED******REMOVED***/ The Floating Panel's current detent.
***REMOVED***@State private var selectedDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED******REMOVED***/ The initial viewpoint shown in the map.
***REMOVED***private let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: dataModel.map,
***REMOVED******REMOVED******REMOVED***viewpoint: initialViewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.floatingPanel(selectedDetent: $selectedDetent, isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***switch demoContent {
***REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanelListDemoContent(selectedDetent: $selectedDetent)
***REMOVED******REMOVED******REMOVED***case .textField:
***REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanelTextFieldDemoContent()
***REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("List") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = .list
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Text Field") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = .textField
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Present")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the Floating Panel is displayed or not.
***REMOVED***var isPresented: Binding<Bool> {
***REMOVED******REMOVED***.init {
***REMOVED******REMOVED******REMOVED***demoContent != nil
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ The types of content available for demo in the Floating Panel.
private enum FloatingPanelDemoContent {
***REMOVED***case textField
***REMOVED***case list
***REMOVED***

***REMOVED***/ Demo content consisting of a list with inner sections each containing a set of buttons This
***REMOVED***/ content also demonstrates the ability to control the Floating Panel's detent.
private struct FloatingPanelListDemoContent: View {
***REMOVED***@Binding var selectedDetent: FloatingPanelDetent
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Section("Preset Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Summary") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .summary
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Half") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .half
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Full") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .full
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Fractional Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("1/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1 / 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("1/2") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1 / 2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("3/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(3 / 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Value Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("200") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(200)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("600") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(600)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ Demo content consisting of a vertical stack of items, including a text field which demonstrates
***REMOVED***/ the Floating Panel's keyboard avoidance capability.
private struct FloatingPanelTextFieldDemoContent: View {
***REMOVED***@State private var sampleText = ""
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***Text("Text Field")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED***Text("The Floating Panel has built-in keyboard avoidance.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***"Text Field",
***REMOVED******REMOVED******REMOVED******REMOVED***text: $sampleText,
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text("Enter sample text.")
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.textFieldStyle(.roundedBorder)
***REMOVED***
***REMOVED***
***REMOVED***
