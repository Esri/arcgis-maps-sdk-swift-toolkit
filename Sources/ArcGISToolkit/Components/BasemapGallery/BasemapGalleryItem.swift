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
***REMOVED******REMOVED***deinit {
***REMOVED******REMOVED******REMOVED***loadBasemapTask.cancel()
***REMOVED******REMOVED******REMOVED***fetchBasemapTask.cancel()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***@Published
***REMOVED***public var loadBasemapsError: Error? = nil

***REMOVED******REMOVED***/ The currently executing async task for loading basemap.
***REMOVED***private var loadBasemapTask: Task<Void, Never>? = nil

***REMOVED******REMOVED***/ The basemap this `BasemapGalleryItem` represents.
***REMOVED***public private(set) var basemap: Basemap

***REMOVED***private var nameOverride: String? = nil
***REMOVED******REMOVED***/ The name of this `Basemap`.
***REMOVED***@Published
***REMOVED***public private(set) var name: String = ""

***REMOVED***private var descriptionOverride: String? = nil
***REMOVED******REMOVED***/ The description which will be used in the gallery.
***REMOVED***@Published
***REMOVED***public private(set) var description: String? = nil

***REMOVED***private var thumbnailOverride: UIImage? = nil
***REMOVED******REMOVED***/ The thumbnail which will be displayed in the gallery.
***REMOVED***@Published
***REMOVED***public private(set) var thumbnail: UIImage? = nil
***REMOVED***
***REMOVED***public private(set) var spatialReference: SpatialReference? = nil
***REMOVED***
***REMOVED***@Published
***REMOVED***public private(set) var isLoaded = false
***REMOVED***

extension BasemapGalleryItem {
***REMOVED***private func loadBasemap() async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***print("pre-basemap.load()")
***REMOVED******REMOVED******REMOVED***try await basemap.load()
***REMOVED******REMOVED******REMOVED***print("basemap loaded!")
***REMOVED******REMOVED******REMOVED***if let loadableImage = basemap.item?.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***TODO: use the item.spatialreferenceName to create a spatial reference instead of always loading the first base layer.
***REMOVED******REMOVED******REMOVED******REMOVED*** Determine the spatial reference of the basemap
***REMOVED******REMOVED******REMOVED******REMOVED***if let item = basemap.item as? PortalItem {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await item.load()
***REMOVED******REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED***print("sr = \(basemap.item?.spatialReferenceName ?? "no name"); item: \(String(describing: (basemap.item as? PortalItem)?.loadStatus))")
***REMOVED******REMOVED******REMOVED***if let layer = basemap.baseLayers.first {
***REMOVED******REMOVED******REMOVED******REMOVED***try await layer.load()
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference = layer.spatialReference
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***TODO:  Add sr checking and setting of sr to bmgi (isValid???); and what to do with errors...
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***await update()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***loadBasemapsError = error
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func update() {
***REMOVED******REMOVED***self.name = nameOverride ?? basemap.name
***REMOVED******REMOVED***self.description = descriptionOverride ?? basemap.item?.description
***REMOVED******REMOVED***self.thumbnail = thumbnailOverride ??
***REMOVED******REMOVED***(basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
***REMOVED******REMOVED***
***REMOVED******REMOVED***isLoaded = true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns whether the basemap gallery item is valid and ok to use.
***REMOVED******REMOVED***/ - Parameter item: item to match spatial references with.
***REMOVED******REMOVED***/ - Returns: true if the item is loaded and either `item`'s spatial reference is nil
***REMOVED******REMOVED***/ or matches `spatialReference`.
***REMOVED***public func isValid(for otherSpatialReference: SpatialReference?) -> Bool {
***REMOVED******REMOVED***print("name: \(name); isLoaded = \(isLoaded); loadStatus = \(basemap.loadStatus)")
***REMOVED******REMOVED***guard isLoaded else { return false ***REMOVED***
***REMOVED******REMOVED***return otherSpatialReference == nil || otherSpatialReference == spatialReference
***REMOVED******REMOVED******REMOVED***return true
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
