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
    
    /// The currently selected map.
    @Binding var selectedMap: Map?
    
    /// A Boolean value indicating whether the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
    /// The download state of the preplanned map model.
    fileprivate enum DownloadState {
        case notDownloaded, downloading, downloaded
    }
    
    /// The current download state of the preplanned map model.
    @State private var downloadState: DownloadState = .notDownloaded
    
    /// The previous download state of the preplanned map model.
    @State private var previousDownloadState: DownloadState = .notDownloaded
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    /// A Boolean value indicating whether the selected map area is the same
    /// as the map area from this model.
    /// The title of a preplanned map area is guaranteed to be unique when it
    /// is created.
    var isSelected: Bool {
        selectedMap?.item?.title == model.preplannedMapArea.title
    }
    
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
                if isSelected {
                    openStatusView
                } else {
                    statusView
                }
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            metadataViewIsPresented = true
        }
        .sheet(isPresented: $metadataViewIsPresented) {
            NavigationStack {
                PreplannedMetadataView(model: model, isSelected: isSelected)
            }
        }
        .task {
            await model.load()
        }
        .onAppear {
            downloadState = .init(model.status)
            previousDownloadState = downloadState
        }
        .onReceive(model.$status) { status in
            let downloadState = DownloadState(status)
            withAnimation(
                downloadState == .downloaded ? .easeInOut : nil
            ) {
                self.downloadState = downloadState
            }
        }
    }
    
    @ViewBuilder private var thumbnailView: some View {
        if let thumbnail = model.preplannedMapArea.thumbnail {
            LoadableImageView(loadableImage: thumbnail) {
                placeholderImage
            } loadedContent: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 44)
                    .clipShape(.rect(cornerRadius: 2))
            }
        } else {
            placeholderImage
        }
    }
    
    @ViewBuilder private var placeholderImage: some View {
        Image(systemName: "map")
            .imageScale(.large)
            .foregroundStyle(.secondary)
            .frame(width: 64, height: 44)
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.preplannedMapArea.title)
            .font(.body)
            .lineLimit(1)
    }
    
    @ViewBuilder private var downloadButton: some View {
        switch downloadState {
        case .downloaded:
            Button {
                if let map = model.map {
                    selectedMap = map
                    dismiss()
                }
            } label: {
                Text("Open")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .disabled(isSelected)
        case .downloading:
            if let job = model.job {
                ProgressView(job.progress)
                    .progressViewStyle(.gauge)
            }
        case .notDownloaded:
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
    
    private var openStatusView: some View {
        HStack(spacing: 4) {
            Text("Currently open")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
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
                Text("Ready to download")
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

private extension PreplannedListItemView.DownloadState {
    /// Creates an instance.
    /// - Parameter state: The preplanned map model download state.
    init(_ state: PreplannedMapModel.Status) {
        self = switch state {
        case .downloaded: .downloaded
        case .downloading: .downloading
        default: .notDownloaded
        }
    }
}

#Preview {
    struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
        var packagingStatus: PreplannedMapArea.PackagingStatus? { .complete }
        var title: String { "Mock Preplanned Map Area" }
        var description: String { "This is the description text" }
        var thumbnail: LoadableImage? { nil }
        
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
            preplannedMapAreaID: .init("preview")!,
            onRemoveDownload: {}
        ),
        selectedMap: .constant(nil)
    )
    .padding()
}
