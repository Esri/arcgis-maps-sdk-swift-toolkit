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
***REMOVED***Toolkit
***REMOVED***

struct FloatingPanelExampleView: View {
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ The Floating Panel's current content.
***REMOVED***@State private var demoContent: FloatingPanelDemoContent?
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map: Map = {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED******REMOVED***map.initialViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***scale: 1_000_000
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return map
***REMOVED***()
***REMOVED***
***REMOVED******REMOVED***/ The Floating Panel's current detent.
***REMOVED***@State private var selectedDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard, edges: .bottom)
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $selectedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let demoContent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch demoContent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanelListDemoContent(selectedDetent: $selectedDetent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .text:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanelTextContent()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .textField:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanelTextFieldDemoContent(selectedDetent: $selectedDetent)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if demoContent != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Dismiss") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Menu("Present") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("List") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = .list
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Text") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = .text
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Text Field") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***demoContent = .textField
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
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
***REMOVED***case list
***REMOVED***case text
***REMOVED***case textField
***REMOVED***

***REMOVED***/ Demo content consisting of a list with inner sections each containing a set of buttons This
***REMOVED***/ content also demonstrates the ability to control the Floating Panel's detent.
private struct FloatingPanelListDemoContent: View {
***REMOVED***@Binding var selectedDetent: FloatingPanelDetent
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Section("Preset Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Full") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .full
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .full)
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Half") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .half
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .half)
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Summary") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .summary
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .summary)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Fractional Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("3/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(3 / 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .fraction(3 / 4))
***REMOVED******REMOVED******REMOVED******REMOVED***Button("1/2") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1 / 2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .fraction(1 / 2))
***REMOVED******REMOVED******REMOVED******REMOVED***Button("1/4") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .fraction(1 / 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .fraction(1 / 4))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Value Heights") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("600") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(600)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .height(600))
***REMOVED******REMOVED******REMOVED******REMOVED***Button("200") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = .height(200)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedDetent == .height(200))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ Demo content consisting of a single instance of short text which demonstrates the Floating
***REMOVED***/ Panel has a stable width, despite the width of its content.
private struct FloatingPanelTextContent: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text("Hello, world!")
***REMOVED***
***REMOVED***

***REMOVED***/ Demo content consisting of a vertical stack of items, including a text field which demonstrates
***REMOVED***/ the Floating Panel's keyboard avoidance capability.
private struct FloatingPanelTextFieldDemoContent: View {
***REMOVED***@Binding var selectedDetent: FloatingPanelDetent
***REMOVED***
***REMOVED***@State private var sampleText = ""
***REMOVED***
***REMOVED***@FocusState private var isFocused
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
***REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED***.textFieldStyle(.roundedBorder)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.onChange(of: selectedDetent) {
***REMOVED******REMOVED******REMOVED***if selectedDetent != .full {
***REMOVED******REMOVED******REMOVED******REMOVED***isFocused = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
