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
***REMOVED***@StateObject private var mapViewModel: MapViewModel
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED******REMOVED***/ The web map to be taken offline.
***REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding private var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the web map is offline disabled.
***REMOVED***private var mapIsOfflineDisabled: Bool {
***REMOVED******REMOVED***onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view with a given web map.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - online: The web map to be taken offline.
***REMOVED******REMOVED***/   - selection: A binding to the currently selected map.
***REMOVED***public init(online: Map, selection: Binding<Map?>) {
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: MapViewModel(map: online))
***REMOVED******REMOVED***onlineMap = online
***REMOVED******REMOVED***_selectedMap = selection
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !mapIsOfflineDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreasView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await loadPreplannedMapModels()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.done
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle(mapAreasLabel)
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***if mapIsOfflineDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineDisabledView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.refreshable {
***REMOVED******REMOVED******REMOVED***await loadPreplannedMapModels()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedMapAreasView: some View {
***REMOVED******REMOVED***switch mapViewModel.preplannedMapModels {
***REMOVED******REMOVED***case .success(let models):
***REMOVED******REMOVED******REMOVED***if !models.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***List(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: selectedMap) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyPreplannedMapAreasView
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***if let urlError = error as? URLError,
***REMOVED******REMOVED******REMOVED***   urlError.code == .notConnectedToInternet {
***REMOVED******REMOVED******REMOVED******REMOVED***offlinePreplannedMapAreasView
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***view(for: error)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var offlinePreplannedMapAreasView: some View {
***REMOVED******REMOVED***if let models = mapViewModel.offlinePreplannedMapModels {
***REMOVED******REMOVED******REMOVED***if !models.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***List(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: selectedMap) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyOfflinePreplannedMapAreasView
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Models are loading map areas from disk.
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private var emptyPreplannedMapAreasView: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Text(noMapAreasTitle)
***REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED***Text(noMapAreasSubtitle)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***private var emptyOfflinePreplannedMapAreasView: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Text(noMapAreasTitle)
***REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED***Text(noDownloadedMapAreasSubtitle)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var offlineDisabledView: some View {
***REMOVED******REMOVED***let labelText = Text(offlineDisabledTitle)
***REMOVED******REMOVED***let descriptionText = Text(offlineDisabledSubtitle)
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
***REMOVED******REMOVED***/ Loads the online and offline preplanned map models.
***REMOVED***private func loadPreplannedMapModels() async {
***REMOVED******REMOVED***await mapViewModel.loadPreplannedMapModels()
***REMOVED******REMOVED***if case .failure = mapViewModel.preplannedMapModels {
***REMOVED******REMOVED******REMOVED***await mapViewModel.loadOfflinePreplannedMapModels()
***REMOVED***
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***@MainActor
***REMOVED***struct OfflineMapAreasViewPreview: View {
***REMOVED******REMOVED***@State private var map: Map?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***OfflineMapAreasView(
***REMOVED******REMOVED******REMOVED******REMOVED***online: Map(
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

private extension OfflineMapAreasView {
***REMOVED***var mapAreasLabel: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Map Areas",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for the map areas view."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noMapAreasTitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "No map areas",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that the map has no map areas."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noMapAreasSubtitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "There are no map areas defined for this web map.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that there are no map areas defined for the web map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var noDownloadedMapAreasSubtitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "There are no downloaded map areas for this web map.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that there are no downloaded map areas for the web map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var offlineDisabledTitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Offline disabled",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that the web map is offline disabled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var offlineDisabledSubtitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Please ensure the web map is offline enabled.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that the user should check that the web map is offline enabled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
