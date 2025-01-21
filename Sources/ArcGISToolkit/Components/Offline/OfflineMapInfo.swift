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

***REMOVED***/ Information for an online map that has been taken offline.
public struct OfflineMapInfo: Codable {
***REMOVED***private var portalItemIDRawValue: String
***REMOVED******REMOVED***/ The title of the portal item associated with the map.
***REMOVED***public var title: String
***REMOVED******REMOVED***/ The description of the portal item associated with the map.
***REMOVED***public var description: String
***REMOVED******REMOVED***/ The URL of the portal item associated with the map.
***REMOVED***public var portalItemURL: URL
***REMOVED***
***REMOVED***internal init?(portalItem: PortalItem) {
***REMOVED******REMOVED***guard let idRawValue = portalItem.id?.rawValue,
***REMOVED******REMOVED******REMOVED***  let url = portalItem.url
***REMOVED******REMOVED***else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.portalItemIDRawValue = idRawValue
***REMOVED******REMOVED***self.title = portalItem.title
***REMOVED******REMOVED***self.description = portalItem.description.replacing(/<[^>]+>/, with: "")
***REMOVED******REMOVED***self.portalItemURL = url
***REMOVED***
***REMOVED***

public extension OfflineMapInfo {
***REMOVED******REMOVED***/ The ID of the portal item associated with the map.
***REMOVED***var portalItemID: Item.ID {
***REMOVED******REMOVED***.init(portalItemIDRawValue)!
***REMOVED***
***REMOVED***
