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

public struct PreplannedListItemView: View {
***REMOVED******REMOVED***/ The view model for the preplanned map.
***REMOVED***@ObservedObject var model: PreplannedMapModel
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED***let preplannedMapArea = model.preplannedMapArea
***REMOVED******REMOVED******REMOVED***if let thumbnail = model.preplannedMapArea.portalItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 2))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!downloadButtonEnabled)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !preplannedMapArea.portalItem.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("This area has no description.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private var downloadButtonEnabled: Bool {
***REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED***case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
***REMOVED******REMOVED******REMOVED******REMOVED***.downloading, .downloaded:
***REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED***case .packaged, .downloadFailure:
***REMOVED******REMOVED******REMOVED***true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED***case .loadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
***REMOVED******REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging")
***REMOVED******REMOVED******REMOVED***case .packaged:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Package ready for download")
***REMOVED******REMOVED******REMOVED***case .packageFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging failed")
***REMOVED******REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloading")
***REMOVED******REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloaded")
***REMOVED******REMOVED******REMOVED***case .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Download failed")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
