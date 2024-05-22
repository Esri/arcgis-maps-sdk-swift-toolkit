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

public struct OfflineMapAreasView: View {
***REMOVED******REMOVED***/ The view model for the map.
***REMOVED***@StateObject private var mapViewModel: MapViewModel
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED***
***REMOVED******REMOVED***/ The rotation angle of the reload button image.
***REMOVED***@State private var rotationAngle: CGFloat = 0.0
***REMOVED***
***REMOVED***public init(map: Map) {
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: MapViewModel(map: map))
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section(header: HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Preplanned Map Areas").bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.linear(duration: 0.6)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotationAngle = rotationAngle + 360
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reload the preplanned map areas.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await mapViewModel.makePreplannedOfflineMapModels()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.clockwise")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(rotationAngle))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.mini)
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreas
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.textCase(nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await mapViewModel.makePreplannedOfflineMapModels()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { dismiss() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Offline Maps")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var preplannedMapAreas: some View {
***REMOVED******REMOVED***switch mapViewModel.preplannedMapModels {
***REMOVED******REMOVED***case .success(let models):
***REMOVED******REMOVED******REMOVED***if mapViewModel.hasPreplannedMapAreas {
***REMOVED******REMOVED******REMOVED******REMOVED***List(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(model: preplannedMapModel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***emptyPreplannedMapAreasView
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var emptyPreplannedMapAreasView: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Text("No offline map areas")
***REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED***Text("You don't have any offline map areas yet.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***

public extension OfflineMapAreasView {
***REMOVED******REMOVED***/ The model class for the offline map areas view.
***REMOVED***@MainActor
***REMOVED***class MapViewModel: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The online map.
***REMOVED******REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The preplanned offline map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the map has preplanned map areas.
***REMOVED******REMOVED***@Published private(set) var hasPreplannedMapAreas = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***self.onlineMap = map
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ offline map models.
***REMOVED******REMOVED***func makePreplannedOfflineMapModels() async {
***REMOVED******REMOVED******REMOVED***preplannedMapModels = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.compactMap {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: $0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels!.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***hasPreplannedMapAreas = !models.isEmpty
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***OfflineMapAreasView(
***REMOVED******REMOVED***map: Map(
***REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED******REMOVED***id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
