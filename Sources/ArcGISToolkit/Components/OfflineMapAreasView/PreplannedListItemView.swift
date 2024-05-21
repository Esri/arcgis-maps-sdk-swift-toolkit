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

public struct PreplannedListItemView: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: PreplannedMapModel
    
    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            let preplannedMapArea = model.preplannedMapArea
            if let thumbnail = model.preplannedMapArea.portalItem.thumbnail {
                LoadableImageView(loadableImage: thumbnail)
                    .frame(width: 64, height: 44)
                    .clipShape(.rect(cornerRadius: 2))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(preplannedMapArea.portalItem.title)
                        .font(.body)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.down.circle")
                    }
                    .disabled(!downloadButtonEnabled)
                }
                if !preplannedMapArea.portalItem.description.isEmpty {
                    Text(preplannedMapArea.portalItem.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else {
                    Text("This area has no description.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                statusView
            }
        }
    }
    
    private var downloadButtonEnabled: Bool {
        switch model.status {
        case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
                .downloading, .downloaded:
            false
        case .packaged, .downloadFailure:
            true
        }
    }
    
    @ViewBuilder private var statusView: some View {
        HStack(spacing: 4) {
            switch model.status {
            case .notLoaded, .loading:
                Text("Loading")
            case .loadFailure:
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
