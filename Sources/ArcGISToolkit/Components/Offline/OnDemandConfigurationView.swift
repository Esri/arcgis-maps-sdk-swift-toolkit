***REMOVED*** Copyright 2025 Esri
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
***REMOVED***

struct OnDemandConfigurationView: View {
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***let map: Map
***REMOVED***@State private var titleInput = ""
***REMOVED***@State private var maxScale: CacheScale = .room
***REMOVED***@State private var polygon: Polygon?
***REMOVED***@State private var currentVisibleArea: Polygon?
***REMOVED***@State private var geometryEditor = GeometryEditor()
***REMOVED***
***REMOVED***var onCompleteAction: ((OnDemandMapAreaConfiguration) -> Void)? = nil
***REMOVED***
***REMOVED***var cannotAddOnDemandArea: Bool {
***REMOVED******REMOVED***titleInput.isEmpty || polygon == nil
***REMOVED***
***REMOVED***
***REMOVED***func onComplete(
***REMOVED******REMOVED***perform action: @escaping (OnDemandMapAreaConfiguration) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCompleteAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Drag the selector to define the area")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 6)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.thinMaterial, ignoresSafeAreaEdges: .horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***mapSelectorView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***bottomPane
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationBarTitle("Select Area")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea(edges: .bottom)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private var bottomPane: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Title")
***REMOVED******REMOVED******REMOVED******REMOVED***TextField("Type here", text: $titleInput)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.trailing)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Picker("Max Scale", selection: $maxScale) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(CacheScale.allCases, id: \.self) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.description)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.pickerStyle(.navigationLink)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if polygon == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***polygon = currentVisibleArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startEditing(polygon: polygon!)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometryEditor.stop()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***polygon = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(polygon == nil ? "Show Selector": "Hide Selector")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tint(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.secondary.opacity(0.4))
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(10)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(currentVisibleArea == nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometryEditor.stop()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let configuration = OnDemandMapAreaConfiguration(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: titleInput,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minScale: CacheScale.worldSmall.scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxScale: maxScale.scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaOfInterest: polygon!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCompleteAction?(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Download")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tint(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(10)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(cannotAddOnDemandArea)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(.bottom, 20)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.background(.thickMaterial)
***REMOVED******REMOVED***.clipShape(
***REMOVED******REMOVED******REMOVED***.rect(
***REMOVED******REMOVED******REMOVED******REMOVED***topLeadingRadius: 10,
***REMOVED******REMOVED******REMOVED******REMOVED***bottomLeadingRadius: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***bottomTrailingRadius: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***topTrailingRadius: 10
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private var mapSelectorView: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.interactionModes([.pan, .zoom])
***REMOVED******REMOVED******REMOVED***.geometryEditor(geometryEditor)
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { area in
***REMOVED******REMOVED******REMOVED******REMOVED***currentVisibleArea = area
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Location Button tapped")
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.slash")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.thinMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***for await polygon in geometryEditor.$geometry {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Update geometry when there is an update.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.polygon = polygon as? Polygon
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func startEditing(polygon: Polygon) {
***REMOVED******REMOVED***let tool = ShapeTool(kind: .rectangle)
***REMOVED******REMOVED***tool.configuration.scaleMode = .stretch
***REMOVED******REMOVED***tool.configuration.allowsRotatingSelectedElement = false
***REMOVED******REMOVED***tool.style.fillSymbol = SimpleFillSymbol(style: .solid, color: .lightGray.withAlphaComponent(0.3))
***REMOVED******REMOVED***geometryEditor.tool = tool
***REMOVED******REMOVED***
***REMOVED******REMOVED***geometryEditor.start(withInitial: polygon)
***REMOVED******REMOVED***geometryEditor.selectGeometry()
***REMOVED******REMOVED***geometryEditor.scaleSelectedElementBy(factorX: 0.8, factorY: 0.8)
***REMOVED***
***REMOVED***
