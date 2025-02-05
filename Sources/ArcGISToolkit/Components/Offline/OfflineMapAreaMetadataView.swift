//
//  PreplannedMetadataView.swift
//  arcgis-maps-sdk-swift-toolkit
//
//  Created by Ryan Olson on 2/5/25.
//


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

import ArcGIS
import SwiftUI

struct OfflineMapAreaMetadataView<Metadata: OfflineMapAreaMetadata>: View {
    /// The view model for the preplanned map.
    @ObservedObject var metadata: Metadata
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating whether the current map area is selected.
    let isSelected: Bool
    
    var body: some View {
        Form {
            Section {
                if let image = metadata.thumbnail {
                    HStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.vertical, 10)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(metadata.title)
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if metadata.description.isEmpty {
                        Text("This area has no description.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text(metadata.description)
                            .font(.subheadline)
                    }
                }
                if metadata.isDownloaded {
                    VStack(alignment: .leading) {
                        Text("Size")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(Int64(metadata.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
                            .font(.subheadline)
                    }
                }
            }
            if !metadata.isDownloaded && !isSelected {
                Section {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .gray.opacity(0.1))
                            .font(.title)
                        Button("Remove Download", role: .destructive) {
                            dismiss()
                            metadata.removeDownloadedArea()
                        }
                    }
                }
            }
            if !metadata.isDownloaded {
                Button("Download", systemImage: "arrow.down.circle") {
                    dismiss()
                    metadata.startDownload()
                }
                .foregroundStyle(Color.accentColor)
                .disabled(!metadata.allowsDownload)
            }
        }
        .navigationTitle(metadata.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

@MainActor
protocol OfflineMapAreaMetadata: ObservableObject {
    var title: String { get }
    var thumbnail: UIImage? { get }
    var description: String { get }
    var isDownloaded: Bool { get }
    var allowsDownload: Bool { get }
    var directorySize: Int { get }
    
    func removeDownloadedArea()
    func startDownload()
}

extension PreplannedMapModel: OfflineMapAreaMetadata {
    var title: String {
        preplannedMapArea.title
    }
    
    var thumbnail: UIImage? {
        nil
    }
    
    var description: String {
        preplannedMapArea.description
    }
    
    var isDownloaded: Bool {
        status.isDownloaded
    }
    
    var allowsDownload: Bool {
        status.allowsDownload
    }
    
    func startDownload() {
        Task { await downloadPreplannedMapArea() }
    }
}

extension OnDemandMapModel: OfflineMapAreaMetadata {
    var description: String { "" }
    
    var isDownloaded: Bool { status.isDownloaded }
    
    var allowsDownload: Bool { false }
    
    func startDownload() { fatalError() }
}
