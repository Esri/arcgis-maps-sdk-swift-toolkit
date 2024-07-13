***REMOVED***
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
import Combine
import UIKit

***REMOVED***/  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
@MainActor
@preconcurrency
public final class BasemapGalleryItem: ObservableObject, Sendable {
***REMOVED******REMOVED***/ The status of a basemap's spatial reference in relation to a reference spatial reference.
***REMOVED***public enum SpatialReferenceStatus: Sendable {
***REMOVED******REMOVED******REMOVED***/ The basemap's spatial reference status is unknown, either because the basemap's
***REMOVED******REMOVED******REMOVED***/ base layers haven't been loaded yet or the status has yet to be updated.
***REMOVED******REMOVED***case unknown
***REMOVED******REMOVED******REMOVED***/ The basemap's spatial reference matches the reference spatial reference.
***REMOVED******REMOVED***case match
***REMOVED******REMOVED******REMOVED***/ The basemap's spatial reference does not match the reference spatial reference.
***REMOVED******REMOVED***case noMatch
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGalleryItem`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - basemap: The `Basemap` represented by the item.
***REMOVED******REMOVED***/   - name: The item name. If `nil`, `Basemap.name` is used, if available.
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
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED***self.thumbnail = thumbnail
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***if basemap.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED***await loadBasemap()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***finalizeLoading()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The basemap represented by `BasemapGalleryItem`.
***REMOVED***public let basemap: Basemap
***REMOVED***
***REMOVED******REMOVED***/ The name of the `basemap`.
***REMOVED***@Published public private(set) var name: String?
***REMOVED***
***REMOVED******REMOVED***/ The description of the `basemap`.
***REMOVED***@Published public private(set) var description: String?
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail used to represent the `basemap`.
***REMOVED***@Published public private(set) var thumbnail: UIImage?

***REMOVED******REMOVED***/ The spatial reference status of the item. This is set via a call to
***REMOVED******REMOVED***/ ``updateSpatialReferenceStatus(_:)``.
***REMOVED***@Published public private(set) var spatialReferenceStatus: SpatialReferenceStatus = .unknown
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the `basemap` or it's base layers are being loaded.
***REMOVED***@Published private(set) var isBasemapLoading = true

***REMOVED******REMOVED***/ The error generated loading the basemap, if any.
***REMOVED***@Published private(set) var loadBasemapError: Error? = nil

***REMOVED******REMOVED***/ The spatial reference of ``basemap``. This will be `nil` until the
***REMOVED******REMOVED***/ basemap's base layers have been loaded by
***REMOVED******REMOVED***/ ``updateSpatialReferenceStatus(_:)``.
***REMOVED***public private(set) var spatialReference: SpatialReference? = nil
***REMOVED***

private extension BasemapGalleryItem {
***REMOVED******REMOVED***/ Loads the basemap and the item's thumbnail, if available.
***REMOVED***func loadBasemap() async {
***REMOVED******REMOVED***var loadError: Error? = nil
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await basemap.load()
***REMOVED******REMOVED******REMOVED***if let loadableImage = basemap.item?.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED***
***REMOVED*** catch  {
***REMOVED******REMOVED******REMOVED***loadError = error
***REMOVED***
***REMOVED******REMOVED***finalizeLoading(error: loadError)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the item in response to basemap loading completion.
***REMOVED******REMOVED***/ - Parameter error: The basemap load error, if any.
***REMOVED***func finalizeLoading(error: Error? = nil) {
***REMOVED******REMOVED***if name == nil {
***REMOVED******REMOVED******REMOVED***name = basemap.name
***REMOVED***
***REMOVED******REMOVED***if description == nil {
***REMOVED******REMOVED******REMOVED***description = basemap.item?.description
***REMOVED***
***REMOVED******REMOVED***if thumbnail == nil {
***REMOVED******REMOVED******REMOVED***thumbnail = basemap.item?.thumbnail?.image ?? .defaultThumbnail()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***loadBasemapError = error
***REMOVED******REMOVED***isBasemapLoading = false
***REMOVED***
***REMOVED***

extension BasemapGalleryItem: Identifiable {***REMOVED***

extension BasemapGalleryItem: Equatable {
***REMOVED***public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
***REMOVED******REMOVED***lhs.basemap === rhs.basemap &&
***REMOVED******REMOVED***lhs.name == rhs.name &&
***REMOVED******REMOVED***lhs.description == rhs.description &&
***REMOVED******REMOVED***lhs.thumbnail === rhs.thumbnail
***REMOVED***
***REMOVED***

public extension BasemapGalleryItem {
***REMOVED******REMOVED***/ Updates the ``spatialReferenceStatus-swift.property`` by loading the first base layer of
***REMOVED******REMOVED***/ ``basemap`` and determining if it matches with the given spatial reference.
***REMOVED******REMOVED***/ - Parameter referenceSpatialReference: The spatial reference to match to.
***REMOVED***@MainActor func updateSpatialReferenceStatus(
***REMOVED******REMOVED***_ referenceSpatialReference: SpatialReference?
***REMOVED***) async throws {
***REMOVED******REMOVED***guard basemap.loadStatus == .loaded else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if spatialReference == nil {
***REMOVED******REMOVED******REMOVED***isBasemapLoading = true
***REMOVED******REMOVED******REMOVED***try await basemap.baseLayers.first?.load()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***finalizeUpdateSpatialReferenceStatus(
***REMOVED******REMOVED******REMOVED***with: referenceSpatialReference
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the item's ``spatialReference`` and ``spatialReferenceStatus-swift.property`` properties.
***REMOVED******REMOVED***/ - Parameter referenceSpatialReference: The spatial reference used to
***REMOVED******REMOVED***/ compare to `basemap`'s spatial reference, represented by the first base layer's
***REMOVED******REMOVED***/ spatial reference.
***REMOVED***@MainActor private func finalizeUpdateSpatialReferenceStatus(
***REMOVED******REMOVED***with referenceSpatialReference: SpatialReference?
***REMOVED***) {
***REMOVED******REMOVED***spatialReference = basemap.baseLayers.first?.spatialReference
***REMOVED******REMOVED***
***REMOVED******REMOVED***if referenceSpatialReference == nil {
***REMOVED******REMOVED******REMOVED***spatialReferenceStatus = .unknown
***REMOVED*** else if spatialReference == referenceSpatialReference {
***REMOVED******REMOVED******REMOVED***spatialReferenceStatus = .match
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***spatialReferenceStatus = .noMatch
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***isBasemapLoading = false
***REMOVED***
***REMOVED***

private extension UIImage {
***REMOVED******REMOVED***/ A default thumbnail image.
***REMOVED******REMOVED***/ - Returns: The default thumbnail.
***REMOVED***static func defaultThumbnail() -> UIImage {
***REMOVED******REMOVED***return UIImage(named: "defaultthumbnail", in: .toolkitModule, with: nil)!
***REMOVED***
***REMOVED***
