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
struct OfflineMapAreaItemView<Model: OfflineMapAreaItem>: View {
    /// The view model for the item view.
    @ObservedObject var model: Model
    
    let isSelected: Bool
    
    @State private var metadataViewIsPresented = false
    
    /// The thumbnail image of the map area.
    @State private var thumbnailImage: UIImage?
    
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
            trailingButton
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
        //.task { await model.load() }
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
            .font(.subheadline)
            .lineLimit(1)
    }
    
    @ViewBuilder private var descriptionView: some View {
        if !model.description.isEmpty {
            Text(model.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        } else {
            Text("No description available.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder private var trailingButton: some View {
        Button {
            // Download map area.
            model.startDownload()
        } label: {
            Image(systemName: "arrow.down.circle")
                .imageScale(.large)
        }
        // Have to apply a style or it won't be tappable
        // because of the onTapGesture modifier in the parent view.
        .buttonStyle(.borderless)
        .disabled(!model.allowsDownload)
        
//        switch downloadState {
//        case .downloaded:
//            Button {
//                if let map = model.map {
//                    selectedMap = map
//                    dismiss()
//                }
//            } label: {
//                Text("Open")
//                    .font(.footnote)
//            }
//            .buttonStyle(.bordered)
//            .buttonBorderShape(.capsule)
//            .disabled(isSelected)
//        case .downloading:
//            if let job = model.job {
//                ProgressView(job.progress)
//                    .progressViewStyle(.gauge)
//            }
//        case .notDownloaded:
//            Button {
//                Task {
//                    // Download preplanned map area.
//                    await model.downloadPreplannedMapArea()
//                }
//            } label: {
//                Image(systemName: "arrow.down.circle")
//                    .imageScale(.large)
//            }
//            // Have to apply a style or it won't be tappable
//            // because of the onTapGesture modifier in the parent view.
//            .buttonStyle(.borderless)
//            .disabled(!model.status.allowsDownload)
//        }
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            Text("Placeholder")
//            switch model.status {
//            case .notLoaded, .loading:
//                Text("Loading")
//            case .loadFailure, .mmpkLoadFailure:
//                Image(systemName: "exclamationmark.circle")
//                Text("Loading failed")
//            case .packaging:
//                Image(systemName: "clock.badge.xmark")
//                Text("Packaging")
//            case .packaged:
//                Text("Ready to download")
//            case .packageFailure:
//                Image(systemName: "exclamationmark.circle")
//                Text("Packaging failed")
//            case .downloading:
//                Text("Downloading")
//            case .downloaded:
//                Text("Downloaded")
//            case .downloadFailure:
//                Image(systemName: "exclamationmark.circle")
//                Text("Download failed")
//            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

@MainActor
protocol OfflineMapAreaItem: ObservableObject, OfflineMapAreaMetadata {
}

#Preview {
    OfflineMapAreaItemView(model: MockMetadata(), isSelected: false)
}

private class MockMetadata: OfflineMapAreaItem {
    var title: String { "Redlands" }
    var thumbnailImage: UIImage? { nil }
    var description: String { "" }
    var isDownloaded: Bool { true }
    var allowsDownload: Bool { true }
    var directorySize: Int { 1_000_000_000 }
    
    func removeDownloadedArea() {}
    func startDownload() {}
}
