***REMOVED*** Copyright 2024 Esri
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

***REMOVED***/ The `OfflineMapAreasView` component displays a list of downloadable preplanned map areas from a given web map.
@MainActor
@preconcurrency
public struct OfflineMapAreasView: View {
***REMOVED******REMOVED***/ The view model for the map.
***REMOVED***@StateObject private var mapViewModel: OfflineMapViewModel
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED******REMOVED***/ The web map to be taken offline.
***REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding private var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ The portal item for the web map to be taken offline.
***REMOVED***private var portalItem: PortalItem {
***REMOVED******REMOVED******REMOVED*** Safe to force cast because of the precondition in the initializer.
***REMOVED******REMOVED***onlineMap.item as! PortalItem
***REMOVED***
***REMOVED***
***REMOVED***private var portalItemID: Item.ID {
***REMOVED******REMOVED******REMOVED*** Safe to force unwrap because of the precondition in the initializer.
***REMOVED******REMOVED***portalItem.id!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view with a given web map.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - onlineMap: The web map to be taken offline.
***REMOVED******REMOVED***/   - selection: A binding to the currently selected map.
***REMOVED******REMOVED***/ - Precondition: `onlineMap.item?.id` is not `nil`.
***REMOVED******REMOVED***/ - Precondition: `onlineMap.item` is of type `PortalItem`.
***REMOVED***public init(onlineMap: Map, selection: Binding<Map?>) {
***REMOVED******REMOVED***precondition(onlineMap.item?.id != nil)
***REMOVED******REMOVED***precondition(onlineMap.item is PortalItem)
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: OfflineManager.shared.model(for: onlineMap))
***REMOVED******REMOVED***self.onlineMap = onlineMap
***REMOVED******REMOVED***_selectedMap = selection
***REMOVED***
***REMOVED***
***REMOVED***public init(mapInfo: OfflineMapInfo, selection: Binding<Map?>) {
***REMOVED******REMOVED***let item = PortalItem(url: mapInfo.portalItemURL)!
***REMOVED******REMOVED***let onlineMap = Map(item: item)
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: OfflineManager.shared.model(for: onlineMap))
***REMOVED******REMOVED***self.onlineMap = onlineMap
***REMOVED******REMOVED***_selectedMap = selection
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !mapViewModel.mapIsOfflineDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreasView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await mapViewModel.loadPreplannedMapModels()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { dismiss() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Map Areas")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***if mapViewModel.mapIsOfflineDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineDisabledView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.refreshable {
***REMOVED******REMOVED******REMOVED***await mapViewModel.loadPreplannedMapModels()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedMapAreasView: some View {
***REMOVED******REMOVED***switch mapViewModel.preplannedMapModels {
***REMOVED******REMOVED***case .success(let models):
***REMOVED******REMOVED******REMOVED***if !models.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***List(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: this logic needs to move out of the view.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OfflineManager.shared.saveMapInfo(for: portalItem)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onRemoveDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard models.filter(\.status.isDownloaded).isEmpty else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OfflineManager.shared.deleteMapInfo(for: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: selectedMap) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyPreplannedMapAreasView
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***view(for: error)
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyPreplannedMapAreasView: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Text("No map areas")
***REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED***Text("There are no map areas defined for this web map.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var offlineDisabledView: some View {
***REMOVED******REMOVED***let labelText = Text("Offline Disabled")
***REMOVED******REMOVED***let descriptionText = Text("Please ensure the web map is offline enabled.")
***REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED***ContentUnavailableView {
***REMOVED******REMOVED******REMOVED******REMOVED***labelText
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED*** description: {
***REMOVED******REMOVED******REMOVED******REMOVED***descriptionText
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***labelText
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED***descriptionText
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func view(for error: Error) -> some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***@MainActor
***REMOVED***struct OfflineMapAreasViewPreview: View {
***REMOVED******REMOVED***@State private var map: Map?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***OfflineMapAreasView(
***REMOVED******REMOVED******REMOVED******REMOVED***onlineMap: Map(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***selection: $map
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***return OfflineMapAreasViewPreview()
***REMOVED***
