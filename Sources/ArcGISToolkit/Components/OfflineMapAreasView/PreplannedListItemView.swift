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
    /// A Boolean value indicating whether the preplanned map area can be downloaded.
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
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if let error {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                switch preplannedMapModel.result {
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                case .failure(let error):
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                        .task {
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
                            .foregroundColor(.secondary)
                        } else {
                            // Map package is available for download.
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { status in
                let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
                if status == .failed || packagingStatus == .processing {
                    // If the preplanned map area fails to load, it may not be packaged.
                    canDownload = false
                } else if packagingStatus == .complete || packagingStatus == nil {
                    // Otherwise, check the packaging status to determine if the map area is
                    // available to download.
                    canDownload = true
                }
            }
            .task {
                do {
                    try await preplannedMapModel.preplannedMapArea.load()
                } catch {
                    if preplannedMapModel.preplannedMapArea.packagingStatus == .complete {
                        self.error = error
                    }
                }
            }
        }
    }
}
