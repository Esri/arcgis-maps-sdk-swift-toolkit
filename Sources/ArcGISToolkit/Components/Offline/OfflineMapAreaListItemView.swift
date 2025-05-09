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

/// A view that shows information for an offline area for use in a List.
@MainActor
struct OfflineMapAreaListItemView<Model: OfflineMapAreaListItemInfo, TrailingContent: View>: View {
    /// Creates an `OfflineMapAreaListItemView`.
    init(
        model: Model,
        isSelected: Bool,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent
    ) {
        self.model = model
        self.isSelected = isSelected
        self.trailingContent = trailingContent
    }
        
    /// The view model for the item view.
    @ObservedObject var model: Model
    
    /// A Boolean value indicating if the map is currently selected.
    private let isSelected: Bool
    
    /// The content to display in the card.
    private let trailingContent: () -> TrailingContent
    
    /// A Boolean value indicating if the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
    /// The thumbnail image of the map area.
    @State private var thumbnailImage: UIImage?
    
    /// The size of the thumbnail.
    private let thumbnailSize: CGFloat = 64
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                metadataViewIsPresented = true
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    thumbnailView
                    VStack(alignment: .leading, spacing: 4) {
                        titleView
                        descriptionView
                        statusView
                    }
                    Spacer()
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            trailingContent()
        }
        .sheet(isPresented: $metadataViewIsPresented) {
            NavigationStack {
                OfflineMapAreaMetadataView(model: model, isSelected: isSelected)
            }
        }
        .task { thumbnailImage = await model.thumbnailImage }
    }
    
    @ViewBuilder private var thumbnailView: some View {
        if let thumbnail = thumbnailImage {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(.rect(cornerRadius: 10))
        } else {
            Image(systemName: "map")
                .imageScale(.large)
                .foregroundStyle(.secondary)
                .frame(width: thumbnailSize, height: thumbnailSize)
                .background(Color(uiColor: UIColor.systemGroupedBackground))
                .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.title)
            .font(.callout)
            .fontWeight(.semibold)
            .lineLimit(1)
    }
    
    @ViewBuilder private var descriptionView: some View {
        if !model.listItemDescription.isEmpty {
            Text(model.listItemDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            if isSelected {
                Text(
                    "Currently open",
                    bundle: .toolkitModule,
                    comment: "The status text for an opened map area."
                )
                .font(.caption2)
                .foregroundStyle(.tertiary)
            } else {
                if !model.statusSystemImage.isEmpty {
                    Image(systemName: model.statusSystemImage)
                }
                Text(model.statusText)
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

@MainActor
protocol OfflineMapAreaListItemInfo: ObservableObject, OfflineMapAreaMetadata {
    var listItemDescription: String { get }
    var statusText: LocalizedStringResource { get }
    var statusSystemImage: String { get }
    var jobProgress: Progress? { get }
    
    func cancelJob()
}

#Preview {
    OfflineMapAreaListItemView(model: MockMetadata(), isSelected: false) {
        Button {} label: {
            Image(systemName: "arrow.down.circle")
                .imageScale(.large)
        }
        // Have to apply a style or it won't be tappable.
        .buttonStyle(.borderless)
    }
}

private class MockMetadata: OfflineMapAreaListItemInfo {
    var title: String { "Redlands" }
    var thumbnailImage: UIImage? { nil }
    var listItemDescription: String { "123 MB" }
    var description: String { "" }
    var isDownloaded: Bool { true }
    var allowsDownload: Bool { true }
    var directorySize: Int { 1_000_000_000 }
    var statusText: LocalizedStringResource { "Downloaded" }
    var statusSystemImage: String { "exclamationmark.circle" }
    var jobProgress: Progress? { nil }
    var dismissMetadataViewOnDelete: Bool { false }
    
    func removeDownloadedArea() {}
    func startDownload() {}
    func cancelJob() {}
}

/// A Button for opening a map area.
struct OpenOfflineMapAreaButton: View {
    /// The currently selected map.
    @Binding var selectedMap: Map?

    /// The map to open.
    let map: Map?
    
    /// Whether or not the map is open.
    let isSelected: Bool
    
    /// The action to dismiss the view.
    /// - Note: If this is not passed in to this view, and we use
    /// the environment here, it doesn't work.
    let dismiss: DismissAction?
    
    var body: some View {
        Button {
            if let map {
                selectedMap = map
                dismiss?()
            }
        } label: {
            Text(
                "Open",
                bundle: .toolkitModule,
                comment: "A label for a button to open a map area."
            )
            .font(.subheadline)
            .fontWeight(.semibold)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .disabled(isSelected)
    }
}

/// A button for downloading a map area.
/// This button is meant to be used in the `OfflineMapAreaListItemView`.
struct DownloadOfflineMapAreaButton<Model: OfflineMapAreaListItemInfo>: View {
    /// The view model for the item view.
    @ObservedObject var model: Model
    
    var body: some View {
        Button {
            model.startDownload()
        } label: {
            Image(systemName: "arrow.down.circle")
                .imageScale(.large)
        }
        // Have to apply a style or it won't be tappable.
        .buttonStyle(.borderless)
        .disabled(!model.allowsDownload)
    }
}

/// A view for displaying the progress of an offline job.
/// This button is meant to be used in the `OfflineMapAreaListItemView`.
struct OfflineJobProgressView<Model: OfflineMapAreaListItemInfo>: View {
    /// The view model for the item view.
    @ObservedObject var model: Model
    
    var body: some View {
        if let progress = model.jobProgress {
            Button {
                model.cancelJob()
            } label: {
                ProgressView(progress)
                    .progressViewStyle(.cancelGauge)
            }
            // Have to apply a style or it won't be tappable.
            .buttonStyle(.plain)
        }
    }
}
