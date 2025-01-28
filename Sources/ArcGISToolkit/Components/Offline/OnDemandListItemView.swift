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
    @ObservedObject var model: OnDemandMapModel
    
    /// The currently selected map.
    @Binding var selectedMap: Map?
    
    /// The download state of the preplanned map model.
    fileprivate enum DownloadState {
        case initialized, downloading, downloaded
    }
    
    @State private var downloadState: DownloadState = .initialized
    
    /// A Boolean value indicating whether the metadata view is presented.
    @State private var metadataViewIsPresented = false
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var isSelected: Bool {
        selectedMap?.item?.title == model.title
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
            if model.status.isDownloaded {
                metadataViewIsPresented = true
            }
        }
        .sheet(isPresented: $metadataViewIsPresented) {
            NavigationStack {
                OnDemandMetadataView(model: model, isSelected: isSelected)
            }
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
    
    // What should we do with the thumbnail? Save our own or use the default one?
    @ViewBuilder private var thumbnailView: some View {
        if downloadState == .downloaded,
           let thumbnail = model.thumbnail {
            LoadableImageView(loadableImage: thumbnail)
                .frame(width: 64, height: 44)
                .clipShape(.rect(cornerRadius: 2))
        } else {
            Image(systemName: "photo.badge.arrow.down")
                .frame(width: 64, height: 44)
                .clipShape(.rect(cornerRadius: 2))
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.title)
            .font(.body)
            .lineLimit(2)
    }
    
    @ViewBuilder private var descriptionView: some View {
        if !model.description.isEmpty {
            Text(model.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        } else {
            Text("This area has no description.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder private var downloadButton: some View {
        switch downloadState {
        case .downloaded:
            Button {
                Task {
                    if let map = model.map {
                        selectedMap = map
                        dismiss()
                    }
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
        case .initialized:
            // This state shouldn't be reached.
            Button {
                Task {
                    await model.downloadOnDemandMapArea()
                }
            } label: {
                Image(systemName: "arrow.down.circle")
            }
            .buttonStyle(.plain)
            .disabled(!model.status.allowsDownload)
            .foregroundStyle(Color.accentColor)
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
            case .initialized:
                Text("Loading")
            case .mmpkLoadFailure:
                Image(systemName: "exclamationmark.circle")
                Text("Loading failed")
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

private extension OnDemandListItemView.DownloadState {
    /// Creates an instance.
    /// - Parameter state: The preplanned map model download state.
    init(_ state: OnDemandMapModel.Status) {
        self = switch state {
        case .downloaded: .downloaded
        case .downloading: .downloading
        default: .initialized
        }
    }
}
