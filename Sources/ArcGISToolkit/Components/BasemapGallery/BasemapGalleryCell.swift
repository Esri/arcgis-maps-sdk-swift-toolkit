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
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***onSelection()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the thumbnail, if available.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnailImage = item.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(make3DBadge(), alignment: .topLeading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(makeOverlay())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.all, 4)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.basemapGallery)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(item.hasError ? .secondary : .primary)
***REMOVED******REMOVED***
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***.contentShape(.hoverEffect, .rect(cornerRadius: 12))
***REMOVED******REMOVED******REMOVED***.hoverEffect()
#endif
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.disabled(item.isBasemapLoading)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a badge which indicates the basemap supports 3D visualization.
***REMOVED******REMOVED***/ - Returns: A 3D badge overlay view.
***REMOVED***@ViewBuilder private func make3DBadge() -> some View {
***REMOVED******REMOVED***if item.is3D {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"3D",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A reference to 3D content."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.font(.basemapGallery)
***REMOVED******REMOVED******REMOVED***.foregroundStyle(item.hasError ? .secondary : .primary)
***REMOVED******REMOVED******REMOVED***.padding(2.5)
***REMOVED******REMOVED******REMOVED***.background(Material.regular)
***REMOVED******REMOVED******REMOVED***.cornerRadius(5)
***REMOVED******REMOVED******REMOVED***.padding(2.5)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an overlay which is either a selection outline or an error icon.
***REMOVED******REMOVED***/ - Returns: A thumbnail overlay view.
***REMOVED***@ViewBuilder private func makeOverlay() -> some View {
***REMOVED******REMOVED***if item.hasError {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For a white background behind the exclamation mark.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 16, height: 16)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 32, height: 32)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(.all, -10)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(lineWidth: isSelected ? 2 : 0)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.accentColor)
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 8))
***REMOVED***
***REMOVED***

extension BasemapGalleryItem {
***REMOVED******REMOVED***/ A Boolean value indicating whether the item has an error.
***REMOVED***var hasError: Bool {
***REMOVED******REMOVED***loadBasemapError != nil ||
***REMOVED******REMOVED***spatialReferenceStatus == .noMatch
***REMOVED***
***REMOVED***

private extension Font {
***REMOVED***static var basemapGallery: Self {
***REMOVED******REMOVED***custom("AvenirNext-Regular", fixedSize: 12)
***REMOVED***
***REMOVED***
