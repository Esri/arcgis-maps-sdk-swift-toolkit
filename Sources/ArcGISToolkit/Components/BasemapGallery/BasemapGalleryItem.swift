***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

import Foundation

***REMOVED***/  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public struct BasemapGalleryItem {
***REMOVED***static var defaultThumbnail: UIImage {
***REMOVED******REMOVED***return UIImage(named: "basemap")!
***REMOVED***
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***basemap: Basemap,
***REMOVED******REMOVED***name: String = "",
***REMOVED******REMOVED***description: String? = "",
***REMOVED******REMOVED***thumbnail: UIImage? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.basemap = basemap
***REMOVED******REMOVED***self.name = name.isEmpty ? basemap.name : name
***REMOVED******REMOVED***self.description = description ?? basemap.item?.description
***REMOVED******REMOVED***self.thumbnail = thumbnail ??
***REMOVED******REMOVED***(basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The basemap this `BasemapGalleryItem` represents.
***REMOVED***public private(set) var basemap: Basemap
***REMOVED***
***REMOVED******REMOVED***/ The name of this `Basemap`.
***REMOVED***public private(set) var name: String
***REMOVED***
***REMOVED******REMOVED***/ The description which will be used in the gallery.
***REMOVED***public private(set) var description: String?
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail which will be displayed in the gallery.
***REMOVED***public let thumbnail: UIImage?
***REMOVED***

extension BasemapGalleryItem: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(basemap) ***REMOVED***
***REMOVED***

extension BasemapGalleryItem: Equatable {
***REMOVED***public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
***REMOVED******REMOVED***lhs.basemap === rhs.basemap &&
***REMOVED******REMOVED***lhs.name == rhs.name &&
***REMOVED******REMOVED***lhs.description == rhs.description &&
***REMOVED******REMOVED***lhs.thumbnail === rhs.thumbnail
***REMOVED***
***REMOVED***
***REMOVED***
