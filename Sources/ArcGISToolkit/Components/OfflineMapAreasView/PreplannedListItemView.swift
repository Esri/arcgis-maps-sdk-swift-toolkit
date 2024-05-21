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
    @State private var packagingStatus: PackagingStatus = .notLoaded
    
    /// The error for the preplanned map.
    @State var error: Error?
    
    /// The packaging status of the preplanned map area.
    enum PackagingStatus {
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
        HStack {
            HStack {
                let preplannedMapArea = preplannedMapModel.preplannedMapArea
                if let thumbnail = preplannedMapModel.preplannedMapArea.portalItem.thumbnail {
                    LoadableImageView(loadableImage: thumbnail)
                        .frame(width: 64, height: 44)
                        .clipShape(.rect(cornerRadius: 2))
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
                    switch packagingStatus {
                    case .notLoaded:
                        // Preplanned map area is still loading.
                        VStack(alignment: .trailing) {
                            ProgressView()
                                .frame(maxWidth: 20)
                                .controlSize(.mini)
                        }
                    case .packaging:
                        // Preplanned map area is still packaging.
                        VStack {
                            Image(systemName: "clock.badge.xmark")
                            Text("packaging")
                                .font(.footnote)
                        }
                        .foregroundStyle(.secondary)
                    case .complete:
                        // Preplanned map area is available for download.
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.down.circle")
                        }
                    case .failed:
                        // An error occured when packaging the preplanned map area.
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { loadStatus in
                let status = preplannedMapModel.preplannedMapArea.packagingStatus
                
                switch loadStatus {
                case .loaded:
                    // Allow downloading the map area when packaging is complete,
                    // or when the packaging status is `nil` for compatibility with
                    // legacy webmaps that have incomplete metadata.
                    withAnimation(.easeIn) {
                        packagingStatus = (status == .complete || status == nil) ? .complete : .packaging
                    }
                case .loading:
                    if status == .processing {
                        // Disable downloading map area when still packaging.
                        packagingStatus = .packaging
                    } else {
                        packagingStatus = .notLoaded
                    }
                case .notLoaded:
                    packagingStatus = .notLoaded
                case .failed:
                    // Disable downloading when the map fails to load.
                    packagingStatus = .failed
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
    }
}
