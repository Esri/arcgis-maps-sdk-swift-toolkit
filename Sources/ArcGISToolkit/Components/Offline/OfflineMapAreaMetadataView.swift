***REMOVED***
***REMOVED***  PreplannedMetadataView.swift
***REMOVED***  arcgis-maps-sdk-swift-toolkit
***REMOVED***
***REMOVED***  Created by Ryan Olson on 2/5/25.
***REMOVED***


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
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = thumbnailImage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: 200)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Name")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(model.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !model.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Description")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(model.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if model.isDownloaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Size")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(Int64(model.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if model.isDownloaded && !isSelected {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "trash.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolRenderingMode(.palette)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red, .gray.opacity(0.1))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Remove Download", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !model.isDownloaded {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Download", systemImage: "arrow.down.circle") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.startDownload()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!model.allowsDownload)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task { thumbnailImage = await model.thumbnailImage ***REMOVED***
***REMOVED******REMOVED***.navigationTitle(model.title)
***REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .confirmationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { dismiss() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

@MainActor
protocol OfflineMapAreaMetadata: ObservableObject {
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { get async ***REMOVED***
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***var isDownloaded: Bool { get ***REMOVED***
***REMOVED***var allowsDownload: Bool { get ***REMOVED***
***REMOVED***var directorySize: Int { get ***REMOVED***
***REMOVED***
***REMOVED***func removeDownloadedArea()
***REMOVED***func startDownload()
***REMOVED***

extension PreplannedMapModel: OfflineMapAreaMetadata {
***REMOVED***var thumbnailImage: UIImage? {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***try? await preplannedMapArea.thumbnail?.load()
***REMOVED******REMOVED******REMOVED***return preplannedMapArea.thumbnail?.image
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var title: String {
***REMOVED******REMOVED***preplannedMapArea.title
***REMOVED***
***REMOVED***
***REMOVED***var description: String {
***REMOVED******REMOVED***preplannedMapArea.description
***REMOVED***
***REMOVED***
***REMOVED***var isDownloaded: Bool {
***REMOVED******REMOVED***status.isDownloaded
***REMOVED***
***REMOVED***
***REMOVED***var allowsDownload: Bool {
***REMOVED******REMOVED***status.allowsDownload
***REMOVED***
***REMOVED***
***REMOVED***func startDownload() {
***REMOVED******REMOVED***Task { await downloadPreplannedMapArea() ***REMOVED***
***REMOVED***
***REMOVED***

extension OnDemandMapModel: OfflineMapAreaMetadata {
***REMOVED***var description: String { "" ***REMOVED***
***REMOVED***
***REMOVED***var isDownloaded: Bool { status.isDownloaded ***REMOVED***
***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { thumbnail ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***var allowsDownload: Bool { false ***REMOVED***
***REMOVED***
***REMOVED***func startDownload() { fatalError() ***REMOVED***
***REMOVED***
