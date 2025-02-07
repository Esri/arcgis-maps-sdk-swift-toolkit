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

@MainActor
private struct OfflineMapAreaItemView<Model: OfflineMapAreaListItem, TrailingContent: View>: View {
    /// Creates an `OfflineMapAreaItemView`.
    init(
        model: Model,
        isSelected: Bool,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent)
    {
        self.model = model
        self.isSelected = isSelected
        self.trailingContent = trailingContent
    }
        
    /// The view model for the item view.
    @ObservedObject var model: Model
    
    /// A Boolean value indicating if the map is currently selected.
    let isSelected: Bool
    
    /// The content to display in the card.
    let trailingContent: () -> TrailingContent
    
    /// A Boolean value indicating if the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
    /// The thumbnail image of the map area.
    @State private var thumbnailImage: UIImage?
    
    /// The size of the thumbnail.
    private let thumbnailSize: CGFloat = 64
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                titleView
                descriptionView
                statusView
            }
            Spacer()
            trailingContent()
        }
        .contentShape(.rect)
        .onTapGesture {
            metadataViewIsPresented = true
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
            Text(model.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            if !model.statusSystemImage.isEmpty {
                Image(systemName: model.statusSystemImage)
            }
            Text(model.statusText)
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

@MainActor
protocol OfflineMapAreaListItem: ObservableObject, OfflineMapAreaMetadata {
    var listItemDescription: String { get }
    var statusText: String { get }
    var statusSystemImage: String { get }
}

#Preview {
    OfflineMapAreaItemView(model: MockMetadata(), isSelected: false) {
        Button {} label: {
            Image(systemName: "arrow.down.circle")
                .imageScale(.large)
        }
        // Have to apply a style or it won't be tappable
        // because of the onTapGesture modifier in the parent view.
        .buttonStyle(.borderless)
    }
}

private class MockMetadata: OfflineMapAreaListItem {
    var title: String { "Redlands" }
    var thumbnailImage: UIImage? { nil }
    var listItemDescription: String { "123 MB" }
    var description: String { "" }
    var isDownloaded: Bool { true }
    var allowsDownload: Bool { true }
    var directorySize: Int { 1_000_000_000 }
    var statusText: String { "Downloaded" }
    var statusSystemImage: String { "exclamationmark.circle" }
    
    func removeDownloadedArea() {}
    func startDownload() {}
}
