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
    @ObservedObject var mapViewModel: OfflineMapAreasView.MapViewModel
    /// The view model for the preplanned map.
    @ObservedObject var preplannedMapModel: PreplannedMapModel
    
    /// A Boolean value indicating whether the preplanned map area can be downloaded. This is `true`
    /// when the preplanned map area is loaded and the packaging status is `.complete`, and `false`
    /// when the packaging status is `.processing`. If the preplanned map area has not yet loaded then
    /// this is `nil`,
    @State private var canDownload: Bool?
    
    /// The error for the preplanned map.
    @State var error: Error?
    
    public var body: some View {
        HStack {
            HStack {
                let preplannedMapArea = preplannedMapModel.preplannedMapArea
                if let thumbnail = preplannedMapModel.preplannedMapArea.portalItem.thumbnail {
                    LoadableImageView(loadableImage: thumbnail)
                        .frame(width: 64, height: 44)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(preplannedMapArea.portalItem.title)
                        .font(.headline)
                    if !preplannedMapArea.portalItem.description.isEmpty {
                        Text(preplannedMapArea.portalItem.description)
                            .font(.caption)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .lineLimit(2)
                    } else {
                        Text("The area has no description.")
                            .font(.caption)
                            .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                    if let error {
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                    }
                }
                Spacer()
                switch preplannedMapModel.result {
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                case .failure(let error):
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                        .onAppear {
                            self.error = error
                        }
                case .none:
                    if let canDownload {
                        if !canDownload {
                            // Map is still packaging.
                            VStack {
                                Image(systemName: "clock.badge.xmark")
                                Text("packaging")
                                    .font(.footnote)
                            }
                            .foregroundStyle(.secondary)
                        } else {
                            // Map package is available for download.
                            Image(systemName: "arrow.down.circle")
                                .foregroundStyle(Color.accentColor)
                        }
                    } else {
                        // Map is still loading.
                        VStack(alignment: .trailing) {
                            ProgressView()
                                .frame(maxWidth: 20)
                                .controlSize(.mini)
                        }
                    }
                }
            }
            .onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { status in
                let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
                
                switch status {
                case .loaded:
                    // Allow downloading the map area when packaging is complete, 
                    // or when the packaging status is `nil` for compatibility with
                    // legacy webmaps that have incomplete metadata.
                    withAnimation(.easeIn) {
                        canDownload = (packagingStatus == .complete || packagingStatus == nil) ? true : false
                    }
                case .loading:
                    // Disable downloading the map area when packaging. Otherwise,
                    // do not set `canDownload` since the map area is still loading.
                    if packagingStatus == .processing {
                        // Disable downloading map area when still packaging.
                        canDownload = false
                    }
                case .notLoaded:
                    // Do not set `canDownload` until map has loaded.
                    return
                case .failed:
                    // Disable downloading when the map fails to load.
                    canDownload = false
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
            .onTapGesture {
                mapViewModel.selectedMap = OfflineMapAreasView.MapViewModel.SelectedMap.preplannedMap(preplannedMapModel)
            }
        }
    }
}
