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
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var isSelected: Bool {
        selectedMap?.item?.title == model.title
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                titleView
                descriptionView
                if isSelected {
                    openStatusView
                } else {
                    statusView
                }
            }
            Spacer()
            trailingButton
        }
        .contentShape(.rect)
        .onTapGesture {
            if model.status.isDownloaded {
                metadataViewIsPresented = true
            }
        }
        .sheet(isPresented: $metadataViewIsPresented) {
            NavigationStack {
                OfflineMapAreaMetadataView(model: model, isSelected: isSelected)
            }
        }
    }
    
    @ViewBuilder private var thumbnailView: some View {
        if let thumbnail = model.thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .opacity(model.isDownloaded ? 1 : 0.5)
                .clipShape(.rect(cornerRadius: 10))
        } else {
            Image(systemName: "map")
                .imageScale(.large)
                .foregroundStyle(.secondary)
                .frame(width: 64, height: 64)
                .background(Color(uiColor: UIColor.systemGroupedBackground))
                .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(model.title)
            .font(.subheadline)
            .lineLimit(1)
            .foregroundStyle(model.isDownloaded ? .primary : .secondary)
    }
    
    @ViewBuilder private var descriptionView: some View {
        if model.isDownloaded {
            Text(Int64(model.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder private var trailingButton: some View {
        switch model.status {
        case .downloading:
            if let job = model.job {
                Button {
                    Task { await job.cancel() }
                } label: {
                    ProgressView(job.progress)
                        .progressViewStyle(CancelGaugeProgressStyle())
                }
                // Have to apply a style or it won't be tappable
                // because of the onTapGesture modifier in the parent view.
                .buttonStyle(.plain)
            }
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
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .disabled(isSelected)
        case .initialized:
            EmptyView()
        case .downloadCancelled, .downloadFailure, .mmpkLoadFailure:
            Button {
                model.removeDownloadedArea()
            } label: {
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
            }
            // Have to apply a style or it won't be tappable
            // because of the onTapGesture modifier in the parent view.
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder private var openStatusView: some View {
        Text("Currently open")
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
            case .downloadCancelled:
                Text("Cancelled")
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

/// A progress view style that shows a cancel square.
struct CancelGaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.accentColor
    var strokeWidth = 3.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .stroke(.quinary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
        }
        .frame(width: 20, height: 20)
    }
}
