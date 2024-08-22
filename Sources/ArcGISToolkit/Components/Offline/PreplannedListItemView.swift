// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

@MainActor
@preconcurrency
struct PreplannedListItemView: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: PreplannedMapModel
    
    /// The closure to perform when the map selection changes.
    let onMapSelectionChanged: (Map) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    titleView
                    Spacer()
                    downloadButton
                }
                descriptionView
                statusView
            }
        }
        .task {
            await model.load()
        }
    }
    
    @ViewBuilder private var thumbnailView: some View {
        if let thumbnail = model.preplannedMapArea.thumbnail {
            LoadableImageView(loadableImage: thumbnail)
                .frame(width: 64, height: 44)
                .clipShape(.rect(cornerRadius: 2))
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.preplannedMapArea.title)
            .font(.body)
    }
    
    @ViewBuilder private var downloadButton: some View {
        switch model.status {
        case .downloaded:
            Button {
                Task {
                    if let map = await model.loadMobileMapPackage() {
                        onMapSelectionChanged(map)
                    }
                }
            } label: {
                Text("Open")
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 76, height: 32)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(.rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        case .downloading:
            if let job = model.job {
                ProgressView(job.progress)
                    .progressViewStyle(.gauge)
            }
        default:
            Button {
                Task {
                    // Download preplanned map area.
                    await model.downloadPreplannedMapArea()
                }
            } label: {
                Image(systemName: "arrow.down.circle")
            }
            .buttonStyle(.plain)
            .disabled(!model.status.allowsDownload)
            .foregroundStyle(Color.accentColor)
        }
    }
    
    @ViewBuilder private var descriptionView: some View {
        if !model.preplannedMapArea.description.isEmpty {
            Text(model.preplannedMapArea.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        } else {
            Text("This area has no description.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            switch model.status {
            case .notLoaded, .loading:
                Text("Loading")
            case .loadFailure, .mmpkLoadFailure:
                Image(systemName: "exclamationmark.circle")
                Text("Loading failed")
            case .packaging:
                Image(systemName: "clock.badge.xmark")
                Text("Packaging")
            case .packaged:
                Text("Package ready for download")
            case .packageFailure:
                Image(systemName: "exclamationmark.circle")
                Text("Packaging failed")
            case .downloading:
                Text("Downloading")
            case .downloaded:
                Text("Downloaded")
            case .downloadFailure:
                Image(systemName: "exclamationmark.circle")
                Text("Download failed")
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

#Preview {
    struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
        var packagingStatus: PreplannedMapArea.PackagingStatus? = .complete
        var title: String = "Mock Preplanned Map Area"
        var description: String = "This is the description text"
        var thumbnail: LoadableImage? = nil
        
        func retryLoad() async throws { }
        func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
            DownloadPreplannedOfflineMapParameters()
        }
    }
    
    return PreplannedListItemView(
        model: PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: MockPreplannedMapArea(),
            portalItemID: .init("preview")!,
            preplannedMapAreaID: .init("preview")!
        )
    ) { _ in }
    .padding()
}
