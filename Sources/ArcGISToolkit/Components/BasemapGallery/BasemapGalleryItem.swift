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

import Foundation
import UIKit.UIImage
***REMOVED***

***REMOVED***/  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public class BasemapGalleryItem: ObservableObject {
***REMOVED******REMOVED***/ Creates a `BasemapGalleryItem`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - basemap: The `Basemap` represented by the item.
***REMOVED******REMOVED***/   - name: The item name. If `nil`, `Basemap.name` is used, if available..
***REMOVED******REMOVED***/   - description: The item description. If `nil`, `Basemap.Item.description`
***REMOVED******REMOVED***/   is used, if available.
***REMOVED******REMOVED***/   - thumbnail: The thumbnail used to represent the item. If `nil`,
***REMOVED******REMOVED***/   `Basemap.Item.thumbnail` is used, if available.
***REMOVED***public init(
***REMOVED******REMOVED***basemap: Basemap,
***REMOVED******REMOVED***name: String? = nil,
***REMOVED******REMOVED***description: String? = nil,
***REMOVED******REMOVED***thumbnail: UIImage? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.basemap = basemap
***REMOVED******REMOVED***self.nameOverride = name
***REMOVED******REMOVED***self.name = name ?? ""
***REMOVED******REMOVED***self.descriptionOverride = description
***REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED***self.thumbnailOverride = thumbnail
***REMOVED******REMOVED***self.thumbnail = thumbnail
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { await loadBasemap() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The error generated loading the basemap, if any.
***REMOVED***@Published
***REMOVED***public private(set) var loadBasemapsError: RuntimeError? = nil
***REMOVED***
***REMOVED******REMOVED***/ The basemap represented by `BasemapGalleryItem`.
***REMOVED***public private(set) var basemap: Basemap
***REMOVED***
***REMOVED******REMOVED***/ The name of the `basemap`.
***REMOVED***@Published
***REMOVED***public private(set) var name: String = ""
***REMOVED***private var nameOverride: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ The description of the `basemap`.
***REMOVED***@Published
***REMOVED***public private(set) var description: String? = nil
***REMOVED***private var descriptionOverride: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail used to represent the `basemap`.
***REMOVED***@Published
***REMOVED***public private(set) var thumbnail: UIImage? = nil
***REMOVED***private var thumbnailOverride: UIImage? = nil
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether the `basemap` or it's base layers are being loaded.
***REMOVED***@Published
***REMOVED***public private(set) var isLoading = true
***REMOVED***

private extension BasemapGalleryItem {
***REMOVED******REMOVED***/ Loads the basemap and the item's thumbnail, if available.
***REMOVED***func loadBasemap() async {
***REMOVED******REMOVED***var loadError: RuntimeError? = nil
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await basemap.load()
***REMOVED******REMOVED******REMOVED***if let loadableImage = basemap.item?.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED***
***REMOVED*** catch  {
***REMOVED******REMOVED******REMOVED***loadError = error as? RuntimeError
***REMOVED***
***REMOVED******REMOVED***await finalizeLoading(error: loadError)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the item in response to basemap loading completion.
***REMOVED******REMOVED***/ - Parameter error: The basemap load error, if any.
***REMOVED***@MainActor
***REMOVED***func finalizeLoading(error: RuntimeError?) {
***REMOVED******REMOVED***name = nameOverride ?? basemap.name
***REMOVED******REMOVED***description = descriptionOverride ?? basemap.item?.description
***REMOVED******REMOVED***thumbnail = thumbnailOverride ??
***REMOVED******REMOVED***(basemap.item?.thumbnail?.image ?? UIImage.defaultThumbnail())
***REMOVED******REMOVED***
***REMOVED******REMOVED***loadBasemapsError = error
***REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED***

extension BasemapGalleryItem: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED***

extension BasemapGalleryItem: Equatable {
***REMOVED***public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
***REMOVED******REMOVED***lhs.basemap === rhs.basemap &&
***REMOVED******REMOVED***lhs.name == rhs.name &&
***REMOVED******REMOVED***lhs.description == rhs.description &&
***REMOVED******REMOVED***lhs.thumbnail === rhs.thumbnail
***REMOVED***
***REMOVED***

private extension UIImage {
***REMOVED******REMOVED***/ A default thumbnail image.
***REMOVED******REMOVED***/ - Returns: The default thumbnail.
***REMOVED***static func defaultThumbnail() -> UIImage {
***REMOVED******REMOVED***return UIImage(named: "DefaultBasemap", in: Bundle.module, with: nil)!
***REMOVED***
***REMOVED***
