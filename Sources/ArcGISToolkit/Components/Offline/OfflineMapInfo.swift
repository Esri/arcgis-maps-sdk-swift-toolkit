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
import Foundation
import OSLog
import UIKit.UIImage

***REMOVED***/ Information for an online map that has been taken offline.
public struct OfflineMapInfo: Sendable {
***REMOVED***private let info: CodableInfo
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail of the portal item associated with the map.
***REMOVED***public let thumbnail: UIImage?
***REMOVED***
***REMOVED***init?(portalItem: PortalItem) async {
***REMOVED******REMOVED***guard let id = portalItem.id?.rawValue,
***REMOVED******REMOVED******REMOVED***  let url = portalItem.url
***REMOVED******REMOVED***else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get the thumbnail.
***REMOVED******REMOVED***try? await portalItem.load()
***REMOVED******REMOVED***if let loadableImage = portalItem.thumbnail {
***REMOVED******REMOVED******REMOVED***try? await loadableImage.load()
***REMOVED******REMOVED******REMOVED***thumbnail = loadableImage.image
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***thumbnail = nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Save the codable info.
***REMOVED******REMOVED***info = .init(
***REMOVED******REMOVED******REMOVED***portalItemID: id,
***REMOVED******REMOVED******REMOVED***title: portalItem.title,
***REMOVED******REMOVED******REMOVED***description: portalItem.description,
***REMOVED******REMOVED******REMOVED***portalItemURL: url
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private init(info: OfflineMapInfo.CodableInfo, thumbnail: UIImage?) {
***REMOVED******REMOVED***self.info = info
***REMOVED******REMOVED***self.thumbnail = thumbnail
***REMOVED***
***REMOVED***
***REMOVED***static func make(from url: URL) -> Self? {
***REMOVED******REMOVED***let infoURL = url.appending(components: "info.json")
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: infoURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED***Logger.offlineManager.debug("Found offline map info at \(infoURL.path())")
***REMOVED******REMOVED***guard let data = try? Data(contentsOf: infoURL),
***REMOVED******REMOVED******REMOVED***  let info = try? JSONDecoder().decode(OfflineMapInfo.CodableInfo.self, from: data)
***REMOVED******REMOVED***else { return nil ***REMOVED***
***REMOVED******REMOVED***return .init(info: info, thumbnail: nil)
***REMOVED***
***REMOVED***
***REMOVED***func save(to url: URL) {
***REMOVED******REMOVED***Logger.offlineManager.debug("Saving pending offline map info to \(url.path())")
***REMOVED******REMOVED***let infoURL = url.appending(path: "info.json")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save info json to file.
***REMOVED******REMOVED***if let data = try? JSONEncoder().encode(info) {
***REMOVED******REMOVED******REMOVED***try? data.write(to: infoURL, options: .atomic)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save thumbnail to file.
***REMOVED******REMOVED***if let thumbnail, let pngData = thumbnail.pngData() {
***REMOVED******REMOVED******REMOVED***let thumbnailURL = url.appending(path: "thumbnail.png")
***REMOVED******REMOVED******REMOVED***try? pngData.write(to: thumbnailURL, options: .atomic)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***static func remove(from url: URL) {
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: url.appending(path: "info.json"))
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: url.appending(path: "thumbnail.png"))
***REMOVED***
***REMOVED***

public extension OfflineMapInfo {
***REMOVED******REMOVED***/ The title of the portal item associated with the map.
***REMOVED***var title: String { info.title ***REMOVED***
***REMOVED******REMOVED***/ The description of the portal item associated with the map.
***REMOVED***var description: String { info.description ***REMOVED***
***REMOVED******REMOVED***/ The URL of the portal item associated with the map.
***REMOVED***var portalItemURL: URL { info.portalItemURL ***REMOVED***
***REMOVED******REMOVED***/ The ID of the portal item associated with the map.
***REMOVED***var portalItemID: Item.ID { .init(info.portalItemID)! ***REMOVED***
***REMOVED***

***REMOVED***/ Information for an online map that has been taken offline.
private extension OfflineMapInfo {
***REMOVED***struct CodableInfo: Codable {
***REMOVED******REMOVED***let portalItemID: String
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***let description: String
***REMOVED******REMOVED***let portalItemURL: URL
***REMOVED***
***REMOVED***
