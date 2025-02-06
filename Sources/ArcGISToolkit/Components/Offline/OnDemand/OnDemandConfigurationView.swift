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
***REMOVED***@State private(set) var map: Map
***REMOVED***
***REMOVED******REMOVED***/ The title of the map area.
***REMOVED***@State private(set) var title: String
***REMOVED***
***REMOVED******REMOVED***/ A check to perform to validate a proposed title for uniqueness.
***REMOVED***let titleIsValidCheck: (String) -> Bool
***REMOVED***
***REMOVED******REMOVED***/ The action to call when creating a configuration is complete.
***REMOVED***let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
***REMOVED***
***REMOVED******REMOVED***/ The max scale of the map to take offline.
***REMOVED***@State private var maxScale: CacheScale = .street
***REMOVED***
***REMOVED******REMOVED***/ The visible area of the map.
***REMOVED***@State private var visibleArea: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ The selected map area.
***REMOVED***@State private var selectedRect: CGRect = .zero
***REMOVED***
***REMOVED******REMOVED***/ The extent of the selected map area.
***REMOVED***@State private var selectedExtent: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating that the map is ready.
***REMOVED***@State private var mapIsReady = false
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Pan and zoom to define the area")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if mapIsReady {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Don't add the selector view until the map is ready.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OnDemandMapAreaSelectorView(selectedMapRect: $selectedRect)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: selectedRect) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedExtent = mapViewProxy.envelope(fromViewRect: selectedRect)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.safeAreaInset(edge: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bottomPane(mapView: mapViewProxy)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { _ in mapIsReady = true ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Prevent view from dragging when panning on map view.
***REMOVED******REMOVED******REMOVED***.highPriorityGesture(DragGesture())
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private func bottomPane(mapView: MapViewProxy) -> some View {
***REMOVED******REMOVED***BottomCard(background: Color(uiColor: .systemBackground)) {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NewTitleButton(title: title, isValidCheck: titleIsValidCheck) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title = $0
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let selectedExtent else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let image = try? await mapView.exportImage()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let thumbnail = image?.crop(to: selectedRect)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let configuration = OnDemandMapAreaConfiguration(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minScale: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxScale: maxScale.scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaOfInterest: selectedExtent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnail: thumbnail
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCompleteAction(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Download", systemImage: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedExtent == nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A View that allows renaming of a map area.
private struct NewTitleButton: View {
***REMOVED******REMOVED***/ The current title.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ An validity check for a proposed title.
***REMOVED***let isValidCheck: (String) -> Bool
***REMOVED***
***REMOVED******REMOVED***/ The completion of the rename.
***REMOVED***let completion: (String) -> Void
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if we are showing the alert to
***REMOVED******REMOVED***/ rename the title.
***REMOVED***@State private var alertIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ Temporary storage for a proposed title for use when the user is renaming an area.
***REMOVED***@State private var proposedNewTitle: String = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the proposed title is valid.
***REMOVED***@State private var proposedTitleIsValid = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED*** Rename the area.
***REMOVED******REMOVED******REMOVED***proposedNewTitle = title
***REMOVED******REMOVED******REMOVED***alertIsShowing = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "pencil")
***REMOVED***
***REMOVED******REMOVED***.alert("Enter a name", isPresented: $alertIsShowing) {
***REMOVED******REMOVED******REMOVED***TextField("Enter area name", text: $proposedNewTitle)
***REMOVED******REMOVED******REMOVED***Button("OK", action: submitNewTitle)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!proposedTitleIsValid)
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {***REMOVED***
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text("The name for the map area must be unique.")
***REMOVED***
***REMOVED******REMOVED***.onChange(of: proposedNewTitle) {
***REMOVED******REMOVED******REMOVED***proposedTitleIsValid = isValidCheck($0)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Completes the rename.
***REMOVED***private func submitNewTitle() {
***REMOVED******REMOVED***completion(proposedNewTitle)
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
***REMOVED***init(background: Background, @ViewBuilder content: @escaping () -> Content) {
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

private extension UIImage {
***REMOVED******REMOVED***/ Crops a UIImage to a certain CGRect of the screen's coordinates.
***REMOVED******REMOVED***/ - Parameter rect: A CGRect in screen coordinates.
***REMOVED******REMOVED***/ - Returns: The cropped image.
***REMOVED***@MainActor
***REMOVED***func crop(to rect: CGRect) -> UIImage? {
***REMOVED******REMOVED***let scale = UIScreen.main.scale
***REMOVED******REMOVED***
***REMOVED******REMOVED***let scaledRect = CGRect(
***REMOVED******REMOVED******REMOVED***x: rect.origin.x * scale,
***REMOVED******REMOVED******REMOVED***y: rect.origin.y * scale,
***REMOVED******REMOVED******REMOVED***width: rect.size.width * scale,
***REMOVED******REMOVED******REMOVED***height: rect.size.height * scale
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let cgImage, let croppedImage = cgImage.cropping(to: scaledRect) else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
***REMOVED***
***REMOVED***
