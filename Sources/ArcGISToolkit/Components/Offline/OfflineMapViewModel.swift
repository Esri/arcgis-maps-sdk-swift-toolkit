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
***REMOVED******REMOVED***/ The mode that we are displaying models in.
***REMOVED***enum Mode {
***REMOVED******REMOVED***case undetermined
***REMOVED******REMOVED***case preplanned
***REMOVED******REMOVED***case onDemand
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The offline map task.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The preplanned map information.
***REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error> = .success([])
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if only offline models are being shown.
***REMOVED***@Published private(set) var isShowingOnlyOfflineModels = false
***REMOVED***
***REMOVED******REMOVED***/ The on-demand map information.
***REMOVED***@Published private(set) var onDemandMapModels = [OnDemandMapModel]()
***REMOVED***
***REMOVED******REMOVED***/ The mode that we are displaying models in.
***REMOVED***@Published private(set) var mode: Mode = .undetermined
***REMOVED***
***REMOVED***@Published private(set) var isLoadingModels: Bool = false

***REMOVED******REMOVED***/ A Boolean value indicating whether the web map is offline disabled.
***REMOVED***@Published private(set) var mapIsOfflineDisabled: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The online map.
***REMOVED***private let onlineMap: Map
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether there are downloaded preplanned map areas for the web map.
***REMOVED***private var hasDownloadedPreplannedMapAreas: Bool {
***REMOVED******REMOVED***if case.success(let preplannedModels) = preplannedMapModels {
***REMOVED******REMOVED******REMOVED***!preplannedModels.filter(\.status.isDownloaded).isEmpty
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether there are downloaded on demand map areas for the web map.
***REMOVED***private var hasDownloadedOnDemandMapAreas: Bool {
***REMOVED******REMOVED***!onDemandMapModels.filter(\.status.isDownloaded).isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether there are downloaded map areas for the web map.
***REMOVED***private var hasDownloadedMapAreas: Bool {
***REMOVED******REMOVED***hasDownloadedPreplannedMapAreas || hasDownloadedOnDemandMapAreas
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
***REMOVED******REMOVED***guard !hasDownloadedMapAreas else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.removeMapInfo(for: portalItemID)
***REMOVED***
***REMOVED***
***REMOVED***var hasAnyPreplannedMapAreas: Bool {
***REMOVED******REMOVED***return switch preplannedMapModels {
***REMOVED******REMOVED***case .success(let success):
***REMOVED******REMOVED******REMOVED***!success.isEmpty
***REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED***false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the preplanned and on-demand models.
***REMOVED***func loadModels() async {
***REMOVED******REMOVED***isLoadingModels = true
***REMOVED******REMOVED***defer { isLoadingModels = false ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Determine if offline is disabled for the map.
***REMOVED******REMOVED***try? await onlineMap.retryLoad()
***REMOVED******REMOVED***mapIsOfflineDisabled = onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
***REMOVED******REMOVED***guard !mapIsOfflineDisabled else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Note: We don't reset the mode once it is determined.
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First load preplanned map models.
***REMOVED******REMOVED***if mode == .undetermined || mode == .preplanned {
***REMOVED******REMOVED******REMOVED***await loadPreplannedMapModels()
***REMOVED******REMOVED******REMOVED***if mode == .undetermined, hasAnyPreplannedMapAreas {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If there are any preplanned map areas at all
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** and the mode is undetermined, then set mode to preplanned.
***REMOVED******REMOVED******REMOVED******REMOVED***mode = .preplanned
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Load on-demand map models if mode is on-demand or still
***REMOVED******REMOVED******REMOVED*** undetermined.
***REMOVED******REMOVED***if mode == .undetermined || mode == .onDemand {
***REMOVED******REMOVED******REMOVED***await loadOnDemandMapModels()
***REMOVED******REMOVED******REMOVED******REMOVED*** If there are any on-demand areas at all, and the mode is
***REMOVED******REMOVED******REMOVED******REMOVED*** undetermined, then set mode to on-demand.
***REMOVED******REMOVED******REMOVED***if mode == .undetermined, !onDemandMapModels.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***mode = .onDemand
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func loadPreplannedMapModels() async {
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
***REMOVED******REMOVED***onDemandMapModels.removeAll(where: { $0 === model ***REMOVED***)
***REMOVED******REMOVED******REMOVED*** Delete the saved map info if there are no more downloads for the
***REMOVED******REMOVED******REMOVED*** represented online map.
***REMOVED******REMOVED***guard !hasDownloadedMapAreas else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.removeMapInfo(for: portalItemID)
***REMOVED***
***REMOVED***
***REMOVED***func loadOnDemandMapModels() async {
***REMOVED******REMOVED***onDemandMapModels = await OnDemandMapModel.loadOnDemandMapModels(portalItemID: portalItemID, onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:))
***REMOVED***
***REMOVED***
***REMOVED***func addOnDemandMapArea(with configuration: OnDemandMapAreaConfiguration) {
***REMOVED******REMOVED***guard mode == .onDemand || mode == .undetermined else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***onDemandMapModels.append(model)
***REMOVED******REMOVED***onDemandMapModels.sort(by: { $0.title < $1.title ***REMOVED***)
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
***REMOVED******REMOVED***var index = onDemandMapModels.count + 1
***REMOVED******REMOVED***while onDemandMapModels.contains(where: { $0.title == title(forIndex: index) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED***index += 1
***REMOVED***
***REMOVED******REMOVED***return title(forIndex: index)
***REMOVED***
***REMOVED***
