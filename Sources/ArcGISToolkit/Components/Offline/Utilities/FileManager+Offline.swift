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

extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***private var documentsDirectory: URL {
***REMOVED******REMOVED***URL.documentsDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory within the documents directory.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/`
***REMOVED***private var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(component: "OfflineMapAreas/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***private func portalItemDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(component: "\(portalItemID)/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the size of a directory and all its contents.
***REMOVED******REMOVED***/ - Parameter url: The directory's URL.
***REMOVED******REMOVED***/ - Returns: The total size in bytes.
***REMOVED***func sizeOfDirectory(at url: URL) -> Int {
***REMOVED******REMOVED***guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 ***REMOVED***
***REMOVED******REMOVED***var accumulatedSize = 0
***REMOVED******REMOVED***for case let fileURL as URL in enumerator {
***REMOVED******REMOVED******REMOVED***guard let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
***REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***accumulatedSize += size
***REMOVED***
***REMOVED******REMOVED***return accumulatedSize
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***func preplannedDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID
***REMOVED***) -> URL {
***REMOVED******REMOVED***portalItemDirectory(forPortalItemID: portalItemID).appending(component: "Preplanned/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the directory for a specific map area from the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>/`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The ID of the web map portal item.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The ID of the preplanned map area portal item.
***REMOVED******REMOVED***/ - Returns: A URL to the preplanned map area directory.
***REMOVED***func preplannedDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID,
***REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID
***REMOVED***) -> URL {
***REMOVED******REMOVED***portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***.appending(components: "Preplanned", "\(preplannedMapAreaID)/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a Boolean value indicating if the specified directory is empty.
***REMOVED******REMOVED***/ - Parameter path: The path to check.
***REMOVED***func isDirectoryEmpty(atPath path: URL) -> Bool {
***REMOVED******REMOVED***(try? FileManager.default.contentsOfDirectory(atPath: path.path()).isEmpty) ?? true
***REMOVED***
***REMOVED***
