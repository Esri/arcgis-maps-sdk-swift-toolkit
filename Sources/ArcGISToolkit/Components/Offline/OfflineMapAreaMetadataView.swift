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
***REMOVED***

struct OfflineMapAreaMetadataView<Metadata: OfflineMapAreaMetadata>: View {
***REMOVED******REMOVED***/ The view model for the preplanned map.
***REMOVED***@ObservedObject var model: Metadata
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the current map area is selected.
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail image of the map area.
***REMOVED***@State private var thumbnailImage: UIImage?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED***Section { header ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !model.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Description") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(model.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if model.isDownloaded && !isSelected {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Remove Download", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !model.isDownloaded {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Download Map") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.startDownload()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!model.allowsDownload)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task { thumbnailImage = await model.thumbnailImage ***REMOVED***
***REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { dismiss() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var header: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = thumbnailImage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 200)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "map")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color(uiColor: UIColor.systemGroupedBackground))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10, style: .continuous))
***REMOVED******REMOVED******REMOVED***.shadow(radius: 5)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 8, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(Color(uiColor: UIColor.systemBackground), lineWidth: 2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(model.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text("Size: \(model.directorySizeText)")
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED***
***REMOVED******REMOVED***.listRowBackground(EmptyView())
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***

***REMOVED***/ The model for the metadata view.
@MainActor
protocol OfflineMapAreaMetadata: ObservableObject {
***REMOVED******REMOVED***/ The title of the area.
***REMOVED***var title: String { get ***REMOVED***
***REMOVED******REMOVED***/ The thumbnail for the area.
***REMOVED***var thumbnailImage: UIImage? { get async ***REMOVED***
***REMOVED******REMOVED***/ The description of the area.
***REMOVED***var description: String { get ***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the area has been downloaded.
***REMOVED***var isDownloaded: Bool { get ***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the area is in a state that allows download.
***REMOVED***var allowsDownload: Bool { get ***REMOVED***
***REMOVED******REMOVED***/ The size of the area on disk.
***REMOVED***var directorySize: Int { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes the downloaded area.
***REMOVED***func removeDownloadedArea()
***REMOVED******REMOVED***/ Starts downloading the area.
***REMOVED***func startDownload()
***REMOVED***

extension OfflineMapAreaMetadata {
***REMOVED***var directorySizeText: String {
***REMOVED******REMOVED***let measurement = Measurement(value: Double(directorySize), unit: UnitInformationStorage.bytes)
***REMOVED******REMOVED***return measurement.formatted(.byteCount(style: .file))
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***OfflineMapAreaMetadataView(model: MockMetadata(), isSelected: false)
***REMOVED***

private class MockMetadata: OfflineMapAreaMetadata {
***REMOVED***var title: String { "Redlands" ***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { nil ***REMOVED***
***REMOVED***var description: String { "" ***REMOVED***
***REMOVED***var isDownloaded: Bool { true ***REMOVED***
***REMOVED***var allowsDownload: Bool { true ***REMOVED***
***REMOVED***var directorySize: Int { 1_000_000_000 ***REMOVED***
***REMOVED***
***REMOVED***func removeDownloadedArea() {***REMOVED***
***REMOVED***func startDownload() {***REMOVED***
***REMOVED***
