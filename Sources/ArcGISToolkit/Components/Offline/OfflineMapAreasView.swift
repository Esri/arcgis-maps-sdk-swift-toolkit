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
public struct OfflineMapAreasView: View {
***REMOVED******REMOVED***/ The view model for the map.
***REMOVED***@StateObject private var mapViewModel: OfflineMapViewModel
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED******REMOVED***/ The web map to be taken offline.
***REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding private var selectedMap: Map?
***REMOVED******REMOVED***/ A Boolean value indicating whether an on-demand map area is being added.
***REMOVED***@State private var isAddingOnDemandArea = false
***REMOVED***
***REMOVED******REMOVED***/ The portal item for the web map to be taken offline.
***REMOVED***private var portalItem: PortalItem {
***REMOVED******REMOVED******REMOVED*** Safe to force cast because of the precondition in the initializer.
***REMOVED******REMOVED***onlineMap.item as! PortalItem
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `ID` of the portal item.
***REMOVED***private var portalItemID: Item.ID {
***REMOVED******REMOVED******REMOVED*** Safe to force unwrap because of the precondition in the initializer.
***REMOVED******REMOVED***portalItem.id!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view with a given web map.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - onlineMap: The web map to be taken offline.
***REMOVED******REMOVED***/   - selection: A binding to the currently selected offline map.
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
***REMOVED******REMOVED***/ Creates a view with a given offline map info.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - offlineMapInfo: The offline map info for which to create the view.
***REMOVED******REMOVED***/   - selection: A binding to the currently selected offline map.
***REMOVED***public init(offlineMapInfo: OfflineMapInfo, selection: Binding<Map?>) {
***REMOVED******REMOVED***let item = PortalItem(url: offlineMapInfo.portalItemURL)!
***REMOVED******REMOVED***let onlineMap = Map(item: item)
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: OfflineManager.shared.model(for: onlineMap))
***REMOVED******REMOVED***self.onlineMap = onlineMap
***REMOVED******REMOVED***_selectedMap = selection
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if mapViewModel.isLoadingModels {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if mapViewModel.mapIsOfflineDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineDisabledView
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch mapViewModel.mode {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .preplanned:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreasView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .onDemand, .undetermined:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapAreasView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED*** This frame is required to set the background to cover the whole view.
***REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise when the progress view is showing, the background will
***REMOVED******REMOVED******REMOVED******REMOVED*** only cover the progress view.
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, maxHeight: .infinity)
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemGroupedBackground))
***REMOVED******REMOVED******REMOVED***#endif
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await mapViewModel.loadModels()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { dismiss() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Map Areas")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedMapAreasView: some View {
***REMOVED******REMOVED***switch mapViewModel.preplannedMapModels {
***REMOVED******REMOVED***case .success(let models):
***REMOVED******REMOVED******REMOVED***if !models.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** footer: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if mapViewModel.isShowingOnlyOfflineModels {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we are showing some models, but only offline models,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** show that information in a footer.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noInternetFooter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.refreshable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await mapViewModel.loadModels() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if mapViewModel.isShowingOnlyOfflineModels {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have no models and no internet, show a content unavailable view.
***REMOVED******REMOVED******REMOVED******REMOVED***noInternetNoAreasView
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If the request was successful, but there are no preplanned
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** map areas, then show empty preplanned map areas view.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This shouldn't happen unless preplanned areas were deleted after establishing
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** preplanned mode on the model. Because there needs to be preplanned areas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** to even establish the preplanned mode.
***REMOVED******REMOVED******REMOVED******REMOVED***emptyPreplannedOfflineAreasView
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED***preplannedErrorView
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var onDemandMapAreasView: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !mapViewModel.onDemandMapModels.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(mapViewModel.onDemandMapModels) { onDemandMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OnDemandListItemView(model: onDemandMapModel, selectedMap: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Add Offline Area") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingOnDemandArea = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyOnDemandOfflineAreasView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $isAddingOnDemandArea) {
***REMOVED******REMOVED******REMOVED***OnDemandConfigurationView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: onlineMap.clone(),
***REMOVED******REMOVED******REMOVED******REMOVED***title: mapViewModel.nextOnDemandAreaTitle(),
***REMOVED******REMOVED******REMOVED******REMOVED***titleIsValidCheck: mapViewModel.isProposeOnDemandAreaTitleUnique(_:)
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***mapViewModel.addOnDemandMapArea(with: $0)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***@ViewBuilder private var refreshPreplannedButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***Task { await mapViewModel.loadModels() ***REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label("Refresh", systemImage: "arrow.clockwise")
***REMOVED***
***REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var noInternetFooter: some View {
***REMOVED******REMOVED***Label("No internet connection. Showing downloaded areas only.", systemImage: "wifi.exclamationmark")
***REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var noInternetNoAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***"No Internet Connection",
***REMOVED******REMOVED******REMOVED***systemImage: "wifi.exclamationmark",
***REMOVED******REMOVED******REMOVED***description: "Could not retrieve map areas for this map."
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyPreplannedOfflineAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***"No Map Areas",
***REMOVED******REMOVED******REMOVED***systemImage: "arrow.down.circle",
***REMOVED******REMOVED******REMOVED***description: "There are no offline map areas for this map."
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedErrorView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***"Error Fetching Map Areas",
***REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle",
***REMOVED******REMOVED******REMOVED***description: "An error occurred while fetching map areas."
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyOnDemandOfflineAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***"No Map Areas",
***REMOVED******REMOVED******REMOVED***systemImage: "arrow.down.circle",
***REMOVED******REMOVED******REMOVED***description: "There are no offline map areas for this map. Tap the button below to get started."
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***isAddingOnDemandArea = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Add Offline Area", systemImage: "plus")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var offlineDisabledView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***"Offline Disabled",
***REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle",
***REMOVED******REMOVED******REMOVED***description: "Please ensure the map is offline enabled."
***REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: Item.ID("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***selection: $map
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***return OfflineMapAreasViewPreview()
***REMOVED***

enum Backported {
***REMOVED******REMOVED***/ A content unavailable view that can be used in older operating systems.
***REMOVED***struct ContentUnavailableView<Actions: View>: View {
***REMOVED******REMOVED***let title: LocalizedStringKey
***REMOVED******REMOVED***let systemImage: String
***REMOVED******REMOVED***let description: String?
***REMOVED******REMOVED***let actions: () -> Actions
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: LocalizedStringKey,
***REMOVED******REMOVED******REMOVED***systemImage name: String,
***REMOVED******REMOVED******REMOVED***description: String? = nil,
***REMOVED******REMOVED******REMOVED***@ViewBuilder actions: @escaping () -> Actions
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED******REMOVED***self.systemImage = name
***REMOVED******REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED******REMOVED***self.actions = actions
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: LocalizedStringKey,
***REMOVED******REMOVED******REMOVED***systemImage name: String,
***REMOVED******REMOVED******REMOVED***description: String? = nil
***REMOVED******REMOVED***) where Actions == EmptyView {
***REMOVED******REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED******REMOVED***self.systemImage = name
***REMOVED******REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED******REMOVED***self.actions = { EmptyView() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED***SwiftUI.ContentUnavailableView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(title, systemImage: systemImage)
***REMOVED******REMOVED******REMOVED*** description: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** actions: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***actions()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: systemImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***actions()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
