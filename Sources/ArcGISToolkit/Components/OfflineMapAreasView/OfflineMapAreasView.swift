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

@MainActor
public struct OfflineMapAreasView: View {
***REMOVED******REMOVED***/ The view model for the map.
***REMOVED***@StateObject private var mapViewModel: MapViewModel
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED***
***REMOVED***public init(map: Map) {
***REMOVED******REMOVED***_mapViewModel = StateObject(wrappedValue: MapViewModel(map: map))
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section(header: Text("Preplanned Map Areas").bold()) {
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
***REMOVED******REMOVED******REMOVED***List(models) { preplannedMapModel in
***REMOVED******REMOVED******REMOVED******REMOVED***PreplannedListItemView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapModel: preplannedMapModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewModel: mapViewModel
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***ProgressView().frame(maxWidth: .infinity)
***REMOVED***
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
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***self.onlineMap = map
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ offline map models.
***REMOVED******REMOVED***func makePreplannedOfflineMapModels() async {
***REMOVED******REMOVED******REMOVED***self.preplannedMapModels = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.compactMap {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: $0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
