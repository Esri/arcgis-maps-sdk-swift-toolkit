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
import Foundation

***REMOVED***/ The model class that represents information for an offline map.
@MainActor
class OfflineMapViewModel: ObservableObject {
***REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The offline map task.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The preplanned map information.
***REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if only offline models are being shown.
***REMOVED***@Published private(set) var isShowingOnlyOfflineModels = false
***REMOVED***
***REMOVED******REMOVED***/ The on-demand map information.
***REMOVED***@Published private(set) var onDemandMapModels: [OnDemandMapModel]?
***REMOVED***
***REMOVED******REMOVED***/ The online map.
***REMOVED***private let onlineMap: Map
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the web map is offline disabled.
***REMOVED***var mapIsOfflineDisabled: Bool {
***REMOVED******REMOVED***onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an offline map areas view model for a given web map.
***REMOVED******REMOVED***/ - Parameter onlineMap: The web map.
***REMOVED******REMOVED***/ - Precondition: `onlineMap.item?.id` is not `nil`.
***REMOVED***init(onlineMap: Map) {
***REMOVED******REMOVED***precondition(onlineMap.item?.id != nil)
***REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
***REMOVED******REMOVED***self.onlineMap = onlineMap
***REMOVED******REMOVED***portalItemID = onlineMap.item!.id!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The function called when a downloaded preplanned map area is removed.
***REMOVED***func onRemoveDownloadOfPreplannedArea() {
***REMOVED******REMOVED******REMOVED*** Delete the saved map info if there are no more downloads for the
***REMOVED******REMOVED******REMOVED*** represented online map.
***REMOVED******REMOVED***guard case.success(let models) = preplannedMapModels,
***REMOVED******REMOVED******REMOVED***  models.filter(\.status.isDownloaded).isEmpty
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.removeMapInfo(for: portalItemID)
***REMOVED***
***REMOVED***
***REMOVED***func loadPreplannedMapModels() async {
***REMOVED******REMOVED***let models = await PreplannedMapModel.loadPreplannedMapModels(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownloadOfPreplannedArea
***REMOVED******REMOVED***)
***REMOVED******REMOVED***preplannedMapModels = models.result
***REMOVED******REMOVED***isShowingOnlyOfflineModels = models.onlyOfflineModelsAreAvailable
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The function called when a downloaded on demand map area is removed.
***REMOVED******REMOVED***/ - Parameter model: The on demand map model.
***REMOVED***func onRemoveDownloadOfOnDemandArea(for model: OnDemandMapModel) {
***REMOVED******REMOVED***guard let models = onDemandMapModels else { return ***REMOVED***
***REMOVED******REMOVED***onDemandMapModels?.removeAll(where: { $0.areaID == model.areaID ***REMOVED***)
***REMOVED******REMOVED******REMOVED*** Delete the saved map info if there are no more downloads for the
***REMOVED******REMOVED******REMOVED*** represented online map.
***REMOVED******REMOVED***guard models.filter(\.status.isDownloaded).isEmpty else { return ***REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.removeMapInfo(for: portalItemID)
***REMOVED***
***REMOVED***
***REMOVED***func loadOnDemandMapModels() async {
***REMOVED******REMOVED***onDemandMapModels = await OnDemandMapModel.loadOnDemandMapModels(portalItemID: portalItemID, onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:))
***REMOVED***
***REMOVED***
***REMOVED***func addOnDemandMapArea(with configuration: OnDemandMapAreaConfiguration) {
***REMOVED******REMOVED***guard onDemandMapModels != nil else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***onDemandMapModels?.append(model)
***REMOVED******REMOVED***onDemandMapModels?.sort(by: { $0.title < $1.title ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED*** Download map area.
***REMOVED******REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns the next title for the on-demand map area.
***REMOVED***func nextOnDemandAreaTitle() -> String {
***REMOVED******REMOVED***func title(forIndex index: Int) -> String {
***REMOVED******REMOVED******REMOVED***"Area \(index)"
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let onDemandMapModels else { return title(forIndex: 1) ***REMOVED***
***REMOVED******REMOVED***var index = onDemandMapModels.count + 1
***REMOVED******REMOVED***while onDemandMapModels.contains(where: { $0.title == title(forIndex: index) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED***index += 1
***REMOVED***
***REMOVED******REMOVED***return title(forIndex: index)
***REMOVED***
***REMOVED***
