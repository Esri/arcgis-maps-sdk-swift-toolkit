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

***REMOVED***/ A row or grid element representing a basemap gallery item.
struct BasemapGalleryCell: View {
***REMOVED******REMOVED***/ The displayed item.
***REMOVED***@ObservedObject var item: BasemapGalleryItem
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the item should be displayed is selected.
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED******REMOVED***/ The action executed when the item is selected.
***REMOVED***let onSelection: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED***onSelection()
***REMOVED***, label: {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the thumbnail, if available.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnailImage = item.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected ? Color.accentColor : Color.clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 3
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display an overlay if the item has an error.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if item.hasError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeErrorOverlay()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display a progress view if the item is loading.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if item.isBasemapLoading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the name of the item.
***REMOVED******REMOVED******REMOVED******REMOVED***Text(item.name ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Font.custom("AvenirNext-Regular", fixedSize: 12))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(item.hasError ? .secondary : .primary)
***REMOVED******REMOVED***
***REMOVED***).disabled(item.isBasemapLoading)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a partially transparent rectangle, used to denote a basemap with an error.
***REMOVED******REMOVED***/ - Returns: A new transparent rectagle view.
***REMOVED***private func makeErrorOverlay() -> some View {
***REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***.opacity(0.75)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a circular progress view with a rounded rectangle background.
***REMOVED******REMOVED***/ - Returns: A new progress view.
***REMOVED***private func makeProgressView() -> some View {
***REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(
***REMOVED******REMOVED******REMOVED******REMOVED***top: 8,
***REMOVED******REMOVED******REMOVED******REMOVED***leading: 12,
***REMOVED******REMOVED******REMOVED******REMOVED***bottom: 8,
***REMOVED******REMOVED******REMOVED******REMOVED***trailing: 12)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemBackground))
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED***
***REMOVED***

extension BasemapGalleryItem {
***REMOVED******REMOVED***/ A Boolean value indicating whether the item has an error.
***REMOVED***var hasError: Bool {
***REMOVED******REMOVED***loadBasemapError != nil ||
***REMOVED******REMOVED***spatialReferenceStatus == .noMatch
***REMOVED***
***REMOVED***
