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
struct PreplannedListItemView: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: PreplannedMapModel
    
    /// The currently selected map.
    @Binding var selectedMap: Map?
    
    /// A Boolean value indicating whether the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
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
        OfflineMapAreaListItemView(model: model, isSelected: isSelected) {
            trailingButton
        }
        .task { await model.load() }
    }
    
    @ViewBuilder private var trailingButton: some View {
        switch model.status {
        case .notLoaded, .loadFailure, .packaging, .packageFailure, .mmpkLoadFailure:
            EmptyView()
        case .loading:
            ProgressView()
        case .packaged, .downloadFailure:
            DownloadOfflineMapAreaButton(model: model)
        case .downloading:
            OfflineJobProgressView(model: model)
        case .downloaded:
            OpenOfflineMapAreaButton(
                selectedMap: $selectedMap,
                map: model.map,
                isSelected: isSelected,
                dismiss: dismiss
            )
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

extension PreplannedMapModel: OfflineMapAreaMetadata {
    var thumbnailImage: UIImage? {
        get async {
            try? await preplannedMapArea.thumbnail?.load()
            return preplannedMapArea.thumbnail?.image
        }
    }
    var title: String { preplannedMapArea.title }
    var description: String { preplannedMapArea.description }
    var isDownloaded: Bool { status.isDownloaded }
    var allowsDownload: Bool { status.allowsDownload }
    var dismissMetadataViewOnDelete: Bool { false }
    
    func startDownload() {
        Task { await downloadPreplannedMapArea() }
    }
}

extension PreplannedMapModel: OfflineMapAreaListItemInfo {
    var listItemDescription: String { description }
    
    var statusText: LocalizedStringResource {
        switch status {
        case .notLoaded, .loading:
                .loading
        case .loadFailure, .mmpkLoadFailure:
                .loadingFailed
        case .packaging:
                .packaging
        case .packaged:
                .readyToDownload
        case .packageFailure:
                .packagingFailed
        case .downloading:
                .downloading
        case .downloaded:
                .downloaded
        case .downloadFailure:
                .downloadFailed
        }
    }
    
    var statusSystemImage: String {
        switch status {
        case .notLoaded, .loading, .packaged, .downloaded, .downloading:
            ""
        case .loadFailure, .mmpkLoadFailure, .downloadFailure:
            "exclamationmark.circle"
        case .packaging:
            "clock.badge.xmark"
        case .packageFailure:
            "exclamationmark.circle"
        }
    }
    
    var jobProgress: Progress? { job?.progress }
}

private extension LocalizedStringResource {
    static var packaging: Self {
        .init(
            "Packaging",
            bundle: .toolkit,
            comment: "The status text when a map area is packaging."
        )
    }
    
    static var readyToDownload: Self {
        .init(
            "Ready to download",
            bundle: .toolkit,
            comment: "The status text when a map area is ready to download."
        )
    }
    
    static var packagingFailed: Self {
        .init(
            "Packaging failed",
            bundle: .toolkit,
            comment: "The status text when a map area packaging failed."
        )
    }
}
