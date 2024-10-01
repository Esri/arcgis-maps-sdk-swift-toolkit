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
    
    /// A Boolean value indicating whether the selected map area is the same
    /// as the map area from this model.
    /// The title of a preplanned map area is guaranteed to be unique when it
    /// is created.
    var isSelected: Bool {
        selectedMap?.item?.title == model.preplannedMapArea.title
    }
    
    /// The closure to perform when the map is removed from local disk.
    var onDeletion: (() -> Void)?
    
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
        .swipeActions {
            deleteButton
        }
        .onTapGesture {
            if model.status.isDownloaded {
                metadataViewIsPresented = true
            }
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
            LoadableImageView(loadableImage: thumbnail)
                .frame(width: 64, height: 44)
                .clipShape(.rect(cornerRadius: 2))
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.preplannedMapArea.title)
            .font(.body)
    }
    
    @ViewBuilder private var deleteButton: some View {
        if model.status.allowsRemoval,
           !isSelected {
            Button(deleteLabel) {
                model.removeDownloadedPreplannedMapArea()
                onDeletion?()
            }
            .tint(.red)
        }
    }
    
    @ViewBuilder private var downloadButton: some View {
        switch downloadState {
        case .downloaded:
            Button {
                Task {
                    if let map = await model.map {
                        selectedMap = map
                    }
                }
            } label: {
                Text(openLabel)
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
            Text(noDescriptionLabel)
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var openStatusView: some View {
        HStack(spacing: 4) {
            Text(currentlyOpenLabel)
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            switch model.status {
            case .notLoaded, .loading:
                Text(loadingLabel)
            case .loadFailure, .mmpkLoadFailure:
                Image(systemName: "exclamationmark.circle")
                Text(loadingFailedLabel)
            case .packaging:
                Image(systemName: "clock.badge.xmark")
                Text(packagingLabel)
            case .packaged:
                Text(packagedLabel)
            case .packageFailure:
                Image(systemName: "exclamationmark.circle")
                Text(packageFailureLabel)
            case .downloading:
                Text(downloadingLabel)
            case .downloaded:
                Text(downloadedLabel)
            case .downloadFailure:
                Image(systemName: "exclamationmark.circle")
                Text(downloadFailureLabel)
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
            preplannedMapAreaID: .init("preview")!
        ),
        selectedMap: .constant(nil)
    )
    .padding()
}

private extension PreplannedListItemView {
    var openLabel: String {
        .init(
            localized: "Open",
            bundle: .toolkitModule,
            comment: "A label for a button to open the map area."
        )
    }
    
    var deleteLabel: String {
        .init(
            localized: "Delete",
            bundle: .toolkitModule,
            comment: "A label for a button to delete the map area."
        )
    }
    
    var noDescriptionLabel: String {
        .init(
            localized: "This area has no description.",
            bundle: .toolkitModule,
            comment: "A label indicating that the map area has no description."
        )
    }
    
    var loadingLabel: String {
        .init(
            localized: "Loading",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area is loading."
        )
    }
    
    var loadingFailedLabel: String {
        .init(
            localized: "Loading failed",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area failed to load."
        )
    }
    
    var packagingLabel: String {
        .init(
            localized: "Packaging",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area is packaging."
        )
    }
    
    var packagedLabel: String {
        .init(
            localized: "Ready to download",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area is packaged."
        )
    }
    
    var packageFailureLabel: String {
        .init(
            localized: "Packaging failed",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area packaging failed."
        )
    }
    
    var downloadingLabel: String {
        .init(
            localized: "Downloading",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area mobile map package is downloading."
        )
    }
    
    var downloadedLabel: String {
        .init(
            localized: "Downloaded",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area mobile map package is downloaded."
        )
    }
    
    var downloadFailureLabel: String {
        .init(
            localized: "Download failed",
            bundle: .toolkitModule,
            comment:  "A status message indicating that the map area mobile map package download failed."
        )
    }
    
    var currentlyOpenLabel: String {
        .init(
            localized: "Currently open",
            bundle: .toolkitModule,
            comment: "A status message indicating that the map area is currently open."
        )
    }
}
