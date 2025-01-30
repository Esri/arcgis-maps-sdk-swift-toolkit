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

***REMOVED***/ A view that can provides a configuration for taking an on-demand area offline.
struct OnDemandConfigurationView: View {
***REMOVED******REMOVED***/ The online map.
***REMOVED***let map: Map
***REMOVED***
***REMOVED******REMOVED***/ The title of the map area.
***REMOVED***@State private(set) var title: String
***REMOVED***
***REMOVED******REMOVED***/ The action to call when creating a configuration is complete.
***REMOVED***let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
***REMOVED***
***REMOVED******REMOVED***/ The max scale of the map to take offline.
***REMOVED***@State private var maxScale: CacheScale = .room
***REMOVED***
***REMOVED******REMOVED***/ The visible area of the map.
***REMOVED***@State private var visibleArea: Envelope?
***REMOVED***
***REMOVED******REMOVED*** The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the download button is disabled.
***REMOVED***var downloadIsDisabled: Bool {
***REMOVED******REMOVED***visibleArea == nil
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Pan and zoom to define the area")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.safeAreaInset(edge: .bottom) {
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
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private var mapView: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.magnifierDisabled(true)
***REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED***.interactionModes([.pan, .zoom])
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0.extent ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private var bottomPane: some View {
***REMOVED******REMOVED***BottomCard(background: Color(uiColor: .systemBackground)) {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker("Level of detail", selection: $maxScale) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(CacheScale.allCases, id: \.self) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.pickerStyle(.navigationLink)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 6)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let visibleArea else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let configuration = OnDemandMapAreaConfiguration(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minScale: CacheScale.worldSmall.scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxScale: maxScale.scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaOfInterest: visibleArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCompleteAction(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Download", systemImage: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(downloadIsDisabled)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view that displays a card with rounded top edges that will be
***REMOVED***/ anchored to the bottom.
private struct BottomCard<Content: View, Background: ShapeStyle>: View {
***REMOVED******REMOVED***/ The content to display in the card.
***REMOVED***let content: () -> Content
***REMOVED******REMOVED***/ The background of the card.
***REMOVED***let background: Background
***REMOVED***
***REMOVED******REMOVED***/ Creates a bottom card.
***REMOVED***init(background: Background,@ViewBuilder content: @escaping () -> Content) {
***REMOVED******REMOVED***self.content = content
***REMOVED******REMOVED***self.background = background
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED***content()
***REMOVED******REMOVED******REMOVED******REMOVED***.background(background)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***topLeadingRadius: 12,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bottomLeadingRadius: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bottomTrailingRadius: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***topTrailingRadius: 12
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** So it extends into the bottom safe area.
***REMOVED******REMOVED******REMOVED***VStack {***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: 1)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(background)
***REMOVED***
***REMOVED******REMOVED***.ignoresSafeArea(.container, edges: .horizontal)
***REMOVED***
***REMOVED***
