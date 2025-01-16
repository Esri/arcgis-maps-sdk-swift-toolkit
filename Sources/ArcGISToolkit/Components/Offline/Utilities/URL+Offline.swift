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

extension URL {
***REMOVED******REMOVED***/ The path to the web map directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***static private func portalItemDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
***REMOVED******REMOVED***return .documentsDirectory.appending(components: "OfflineMapAreas", "\(portalItemID)/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the directory for a specific map area from the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>/`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The ID of the web map portal item.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The ID of the preplanned map area portal item.
***REMOVED******REMOVED***/ - Returns: A URL to the preplanned map area directory.
***REMOVED***static func preplannedDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID,
***REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID? = nil
***REMOVED***) -> URL {
***REMOVED******REMOVED***var url = portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***.appending(component: "Preplanned/")
***REMOVED******REMOVED***if let preplannedMapAreaID {
***REMOVED******REMOVED******REMOVED***url = url.appending(component: "\(preplannedMapAreaID)/")
***REMOVED***
***REMOVED******REMOVED***return url
***REMOVED***
***REMOVED***
***REMOVED***static func onDemandDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID,
***REMOVED******REMOVED***onDemandMapAreaID: UUID? = nil
***REMOVED***) -> URL {
***REMOVED******REMOVED***var url = portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***.appending(component: "OnDemand/")
***REMOVED******REMOVED***if let onDemandMapAreaID {
***REMOVED******REMOVED******REMOVED***url = url.appending(component: "\(onDemandMapAreaID.uuidString)/")
***REMOVED***
***REMOVED******REMOVED***return url
***REMOVED***
***REMOVED***
