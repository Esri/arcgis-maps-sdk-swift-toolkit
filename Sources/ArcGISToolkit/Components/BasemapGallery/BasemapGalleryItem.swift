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
public class BasemapGalleryItem: ObservableObject {
***REMOVED***static var defaultThumbnail: UIImage {
***REMOVED******REMOVED***return UIImage(named: "DefaultBasemap")!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGalleryItem`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - basemap: The `Basemap` represented by the item.
***REMOVED******REMOVED***/   - name: The item name.
***REMOVED******REMOVED***/   - description: The item description.
***REMOVED******REMOVED***/   - thumbnail: The thumbnail used to represent the item.
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
***REMOVED******REMOVED***loadBasemapTask = Task { await loadBasemap() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@Published
***REMOVED***public var loadBasemapsError: Error? = nil

***REMOVED******REMOVED***/ The basemap this `BasemapGalleryItem` represents.
***REMOVED***public private(set) var basemap: Basemap

***REMOVED******REMOVED***/ The name of this `Basemap`.
***REMOVED***@Published
***REMOVED***public private(set) var name: String = ""
***REMOVED***private var nameOverride: String? = nil

***REMOVED******REMOVED***/ The description which will be used in the gallery.
***REMOVED***@Published
***REMOVED***public private(set) var description: String? = nil
***REMOVED***private var descriptionOverride: String? = nil

***REMOVED******REMOVED***/ The thumbnail which will be displayed in the gallery.
***REMOVED***@Published
***REMOVED***public private(set) var thumbnail: UIImage? = nil
***REMOVED***private var thumbnailOverride: UIImage? = nil
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether loading the `basemap` has been attempted.
***REMOVED******REMOVED***/ If the loading of the item generates an error, `isLoaded` will be true.
***REMOVED***@Published
***REMOVED***public private(set) var isLoaded = false

***REMOVED******REMOVED***/ The currently executing async task for loading basemap.
***REMOVED***private var loadBasemapTask: Task<Void, Never>? = nil
***REMOVED***

extension BasemapGalleryItem {
***REMOVED***private func loadBasemap() async {
***REMOVED******REMOVED***var loadError: Error? = nil
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await basemap.load()
***REMOVED******REMOVED******REMOVED***if let loadableImage = basemap.item?.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED***
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***loadError = error
***REMOVED***
***REMOVED******REMOVED***await update(error: loadError)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func update(error: Error?) {
***REMOVED******REMOVED***name = nameOverride ?? basemap.name
***REMOVED******REMOVED***description = descriptionOverride ?? basemap.item?.description
***REMOVED******REMOVED***thumbnail = thumbnailOverride ??
***REMOVED******REMOVED***(basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
***REMOVED******REMOVED***loadBasemapsError = error
***REMOVED******REMOVED***isLoaded = true
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
