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

***REMOVED***/ The `OfflineMapAreasView` displays a list of downloadable preplanned or
***REMOVED***/ on-demand map areas from a given web map.
***REMOVED***/
***REMOVED***/ The view allows users to download, view, and manage offline maps
***REMOVED***/ when network connectivity is poor or nonexistent.
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ The view supports both ahead-of-time(preplanned) and on-demand workflows
***REMOVED***/ for offline mapping. For both workflows, the view:
***REMOVED***/
***REMOVED***/ - Opens a map area for viewing when selected.
***REMOVED***/ - Shows download progress and status for map areas.
***REMOVED***/ - Provides options to view details about downloaded map areas.
***REMOVED***/ - Supports removing downloaded offline map areas files from the device.
***REMOVED***/
***REMOVED***/ For preplanned workflows, the view:
***REMOVED***/
***REMOVED***/ - Displays a list of available preplanned map areas from a offline-enabled
***REMOVED***/ web map that contains preplanned map areas when the network is connected.
***REMOVED***/ - Displays a list of downloaded preplanned map areas on the device
***REMOVED***/ when the network is disconnected.
***REMOVED***/
***REMOVED***/ For on-demand workflows, the view:
***REMOVED***/
***REMOVED***/ - Allows users to add on-demand map areas to the device for offline use.
***REMOVED***/ - Displays a list of on-demand map areas available on the device that are
***REMOVED***/ tied to a specific web map.
***REMOVED***/ - Opens an on-demand map area for viewing when selected.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The `OfflineMapAreasView` needs to be presented modally.
***REMOVED***/
***REMOVED***/ The view can be initialized with a web map or an offline map info.
***REMOVED***/ Therefore, the view can be used either when the device is connected to
***REMOVED***/ or disconnected from the network. In other words, the view can be used
***REMOVED***/ in all 4 situations: (device) connected/preplanned, connected/on-demand,
***REMOVED***/ disconnected/preplanned, disconnected/on-demand.
***REMOVED***/
***REMOVED***/ The view will automatically determine the mode based on the web map.
***REMOVED***/ When the web map contains preplanned map areas, the view will be in
***REMOVED***/ preplanned mode. Otherwise, it will be in on-demand mode. Once the view
***REMOVED***/ is in a mode, it will remain in the same mode for the duration of the view's
***REMOVED***/ lifecycle.
***REMOVED***/
***REMOVED***/ If the network connectivity changes while the view is presented, the view
***REMOVED***/ will not automatically refresh the list of map areas. The user can
***REMOVED***/ pull-to-refresh to reload the list of map areas. Depending on the network
***REMOVED***/ connectivity, the view will display the appropriate content.
***REMOVED***/
***REMOVED***/ During the various stages of the load and download process, the view will
***REMOVED***/ display loading indicator, progress view, and errors to indicate the status.
***REMOVED***/
***REMOVED***/ **Associated Types**
***REMOVED***/
***REMOVED***/ `OfflineMapAreasView` has the following associated types:
***REMOVED***/
***REMOVED***/ - ``OfflineManager``
***REMOVED***/ - ``OfflineMapInfo``
***REMOVED***/
***REMOVED***/ To learn more about the offline manager that downloads and manages offline
***REMOVED***/ map areas without the integrated UI, see the the API doc for `OfflineManager`.
***REMOVED***/
***REMOVED***/ To learn more about using the `OfflineMapAreasView` see the <doc:OfflineMapAreasViewTutorial>.
***REMOVED***/ - Since: 200.7
public struct OfflineMapAreasView: View {
***REMOVED******REMOVED***/ The view model for the map.
***REMOVED***@StateObject private var mapViewModel: OfflineMapViewModel
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED******REMOVED***/ The web map to be taken offline.
***REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding private var selectedMap: Map?
***REMOVED******REMOVED***/ A Boolean value indicating whether an on-demand map area is being added.
***REMOVED***@State private var isAddingOnDemandArea = false
***REMOVED******REMOVED***/ The visibility of the done button.
***REMOVED***private var doneVisibility: Visibility = .automatic
***REMOVED******REMOVED***/ A Boolean value indicating whether the view should dismiss.
***REMOVED***private var shouldDismiss: Bool {
***REMOVED******REMOVED***doneVisibility == .automatic || doneVisibility == .visible
***REMOVED***
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
***REMOVED******REMOVED***/ Specifies the visibility of the done button.
***REMOVED******REMOVED***/ - Parameter visibility: The preferred visibility of the done button.
***REMOVED***public func doneButton(_ visibility: Visibility) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.doneVisibility = visibility
***REMOVED******REMOVED***return copy
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
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: the sheet has to be here rather than off of the `onDemandMapAreasView`
***REMOVED******REMOVED******REMOVED******REMOVED*** or else the state is lost when backgrounding and foregrounding the application.
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isAddingOnDemandArea) {
***REMOVED******REMOVED******REMOVED******REMOVED***OnDemandConfigurationView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: onlineMap.clone(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: mapViewModel.nextOnDemandAreaTitle(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***titleIsValidCheck: mapViewModel.isProposeOnDemandAreaTitleUnique(_:)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewModel.addOnDemandMapArea(with: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***if shouldDismiss {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button.done {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle(
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Map Areas",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A title for the offline map areas view."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model: preplannedMapModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap: $selectedMap,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldDismiss: shouldDismiss
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OnDemandListItemView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model: onDemandMapModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap: $selectedMap,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldDismiss: shouldDismiss
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingOnDemandArea = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***addMapArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyOnDemandOfflineAreasView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var refreshPreplannedButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***Task { await mapViewModel.loadModels() ***REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Refresh",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to refresh map area content."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.clockwise")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var noInternetFooter: some View {
***REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED***noInternetFooterErrorMessage
***REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "wifi.exclamationmark")
***REMOVED***
***REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var noInternetNoAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***.noInternetConnectionErrorMessage,
***REMOVED******REMOVED******REMOVED***systemImage: "wifi.exclamationmark",
***REMOVED******REMOVED******REMOVED***description: noMapAreasErrorMessage
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyPreplannedOfflineAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***noMapAreas,
***REMOVED******REMOVED******REMOVED***systemImage: "arrow.down.circle",
***REMOVED******REMOVED******REMOVED***description: noOfflineMapAreasMessage
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedErrorView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***errorFetchingAreas,
***REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle",
***REMOVED******REMOVED******REMOVED***description: errorFetchingAreasMessage
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***refreshPreplannedButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyOnDemandOfflineAreasView: some View {
***REMOVED******REMOVED***Backported.ContentUnavailableView(
***REMOVED******REMOVED******REMOVED***noMapAreas,
***REMOVED******REMOVED******REMOVED***systemImage: "arrow.down.circle",
***REMOVED******REMOVED******REMOVED***description: emptyOnDemandMessage
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***isAddingOnDemandArea = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***addMapArea
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***offlineDisabled,
***REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle",
***REMOVED******REMOVED******REMOVED***description: offlineDisabledMessage
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
***REMOVED******REMOVED***let title: LocalizedStringResource
***REMOVED******REMOVED***let systemImage: String
***REMOVED******REMOVED***let description: LocalizedStringResource?
***REMOVED******REMOVED***let actions: () -> Actions
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: LocalizedStringResource,
***REMOVED******REMOVED******REMOVED***systemImage name: String,
***REMOVED******REMOVED******REMOVED***description: LocalizedStringResource? = nil,
***REMOVED******REMOVED******REMOVED***@ViewBuilder actions: @escaping () -> Actions
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED******REMOVED***self.systemImage = name
***REMOVED******REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED******REMOVED***self.actions = actions
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: LocalizedStringResource,
***REMOVED******REMOVED******REMOVED***systemImage name: String,
***REMOVED******REMOVED******REMOVED***description: LocalizedStringResource? = nil
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(title.key, systemImage: systemImage)
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

private extension OfflineMapAreasView {
***REMOVED***var addMapArea: Text {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Add Map Area",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to add a map area."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noInternetFooterErrorMessage: Text {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"No internet connection. Showing downloaded areas only.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "An error message explaining that there is no internet connection and only downloaded areas are shown."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noMapAreasErrorMessage: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Could not retrieve map areas for this map.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "An error message explaining that map areas could not be retrieved for this map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noOfflineMapAreasMessage: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"There are no map areas for this map.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A message explaining that there are no map areas for this map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var errorFetchingAreas: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Error Fetching Map Areas",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that an error occurred while fetching map areas."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var errorFetchingAreasMessage: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"An error occurred while fetching map areas.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "An error message for when fetching map areas fails."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noMapAreas: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"No Map Areas",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that there are no map areas."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var emptyOnDemandMessage: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"There are no map areas for this map. Tap the button below to get started.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A message explaining that there are no map areas for this map and to tap the button below to add a map area."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var offlineDisabled: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Offline Disabled",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that the map is offline disabled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var offlineDisabledMessage: LocalizedStringResource {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"The map is not enabled for offline use.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "A message indicating that the map is not offline enabled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
