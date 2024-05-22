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
    @ObservedObject var preplannedMapModel: PreplannedMapModel
    
    /// The packaging status for the preplanned map area.
    @State private var areaStatus: AreaStatus = .notLoaded
    
    /// The error for the preplanned map.
    @State var error: Error?
    
    /// The packaging status of the preplanned map area.
    private enum AreaStatus {
        /// The map area has not yet loaded.
        case notLoaded
        /// The map area is still packaging.
        case packaging
        /// The map area packaging is complete.
        case complete
        /// The map area packaging failed.
        case failed
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            let preplannedMapArea = preplannedMapModel.preplannedMapArea
            if let thumbnail = preplannedMapModel.preplannedMapArea.portalItem.thumbnail {
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
        .onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { loadStatus in
            let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
            
            switch loadStatus {
            case .loaded:
                // Allow downloading the map area when packaging is complete,
                // or when the packaging status is `nil` for compatibility with
                // legacy webmaps that have incomplete metadata.
                withAnimation(.easeIn) {
                    areaStatus = (packagingStatus == .complete || packagingStatus == nil) ? .complete : .packaging
                }
            case .loading:
                if packagingStatus == .processing {
                    // Disable downloading map area when still packaging.
                    areaStatus = .packaging
                } else {
                    areaStatus = .notLoaded
                }
            case .notLoaded:
                areaStatus = .notLoaded
            case .failed:
                areaStatus = packagingStatus == .processing ? .packaging : .failed
            }
        }
        .task {
            do {
                // Load preplanned map area to load packaging status.
                try await preplannedMapModel.preplannedMapArea.load()
            } catch {
                // Present the error if the map area has been packaged. Otherwise,
                // ignore the error when the map area is still packaging since the map
                // area cannot load while packaging.
                if preplannedMapModel.preplannedMapArea.packagingStatus == .complete {
                    self.error = error
                }
            }
        }
    }
    
    var downloadButtonEnabled: Bool {
        return switch preplannedMapModel.result {
        case .success:
            false
        case .failure:
            true
        case .none:
            switch areaStatus {
            case .notLoaded, .packaging, .failed:
                false
            case .complete:
                true
            }
        }
    }
    
    @ViewBuilder var statusView: some View {
        HStack(spacing: 4) {
            switch preplannedMapModel.result {
            case .success:
                Image(systemName: "checkmark.circle.fill")
                Text("Downloaded")
            case .failure:
                Image(systemName: "exclamationmark.circle")
                Text("Download Failed")
            case .none:
                switch areaStatus {
                case .notLoaded:
                    // Preplanned map area is still loading.
                    Text("Loading")
                case .packaging:
                    // Preplanned map area is still packaging.
                    Image(systemName: "clock.badge.xmark")
                    Text("Packaging")
                case .complete:
                    Text("Package ready for download")
                case .failed:
                    Image(systemName: "exclamationmark.circle")
                    if preplannedMapModel.preplannedMapArea.loadStatus == .failed {
                        Text("Loading failed")
                    } else {
                        Text("Packaging failed")
                    }
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}
