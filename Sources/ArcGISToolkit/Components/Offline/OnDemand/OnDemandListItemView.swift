// Copyright 2025 Esri
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

struct OnDemandListItemView: View {
    /// The model for this view.
    @ObservedObject var model: OnDemandMapModel
    
    /// The currently selected map.
    @Binding var selectedMap: Map?
    
    /// A Boolean value indicating whether the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    var isSelected: Bool {
        selectedMap?.item?.title == model.title
    }
    
    /// A Boolean value indicating whether the view should dismiss.
    let shouldDismiss: Bool
    
    var body: some View {
        OfflineMapAreaListItemView(model: model, isSelected: isSelected) {
            trailingButton
        }
    }
    
    @ViewBuilder private var trailingButton: some View {
        switch model.status {
        case .downloading:
            OfflineJobProgressView(model: model)
        case .downloaded:
            OpenOfflineMapAreaButton(
                selectedMap: $selectedMap,
                map: model.map,
                isSelected: isSelected,
                dismiss: shouldDismiss ? dismiss : nil
            )
        case .initialized:
            EmptyView()
        case .downloadCancelled, .downloadFailure, .mmpkLoadFailure:
            removeDownloadButton
        }
    }
    
    @ViewBuilder private var removeDownloadButton: some View {
        Button {
            model.removeDownloadedArea()
        } label: {
            Image(systemName: "xmark.circle")
                .imageScale(.large)
        }
        // Have to apply a style or it won't be tappable.
        .buttonStyle(.borderless)
    }
}

extension OnDemandMapModel: OfflineMapAreaMetadata {
    var description: String { "" }
    var isDownloaded: Bool { status.isDownloaded }
    var thumbnailImage: UIImage? { thumbnail }
    var allowsDownload: Bool { false }
    var dismissMetadataViewOnDelete: Bool { true }
    func startDownload() { fatalError() }
}

extension OnDemandMapModel: OfflineMapAreaListItemInfo {
    var listItemDescription: String {
        switch status {
        case .downloaded:
            directorySizeText
        default:
            ""
        }
    }
    
    var statusText: LocalizedStringResource {
        switch status {
        case .initialized: .loading
        case .mmpkLoadFailure: .loadingFailed
        case .downloading: .downloading
        case .downloaded: .downloaded
        case .downloadFailure: .downloadFailed
        case .downloadCancelled: .cancelled
        }
    }
    
    /// The system image for the current status.
    var statusSystemImage: String {
        switch status {
        case .initialized, .downloading, .downloaded, .downloadCancelled:
            ""
        case .mmpkLoadFailure, .downloadFailure:
            "exclamationmark.circle"
        }
    }
    
    var jobProgress: Progress? { job?.progress }
}

private extension LocalizedStringResource {
    static var cancelled: Self {
        .init(
            "Cancelled",
            bundle: .toolkit,
            comment: "The status text when a map area download is cancelled."
        )
    }
}
