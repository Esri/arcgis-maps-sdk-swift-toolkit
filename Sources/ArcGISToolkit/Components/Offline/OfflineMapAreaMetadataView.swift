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

import ArcGIS
import SwiftUI

struct OfflineMapAreaMetadataView<Metadata: OfflineMapAreaMetadata>: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: Metadata
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating whether the current map area is selected.
    let isSelected: Bool
    
    /// The thumbnail image of the map area.
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        Form {
            Section { header }
            
            if !model.description.isEmpty {
                Section("Description") {
                    Text(model.description)
                        .foregroundStyle(.secondary)
                }
            }
            
            if model.isDownloaded && !isSelected {
                Section {
                    Button("Remove Download", role: .destructive) {
                        dismiss()
                        model.removeDownloadedArea()
                    }
                }
            }
            
            if !model.isDownloaded {
                Section {
                    Button("Download Map") {
                        dismiss()
                        model.startDownload()
                    }
                    .disabled(!model.allowsDownload)
                }
            }
        }
        .task { thumbnailImage = await model.thumbnailImage }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
    
    @ViewBuilder private var header: some View {
        VStack {
            Group {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                } else {
                    Image(systemName: "map")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color(uiColor: UIColor.systemGroupedBackground))
                }
            }
            .clipShape(.rect(cornerRadius: 10, style: .continuous))
            .shadow(radius: 5)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(uiColor: UIColor.systemBackground), lineWidth: 2)
            }
            .padding()
            
            Text(model.title)
                .lineLimit(1)
                .font(.title2)
                .fontWeight(.bold)
            
//            if model.isDownloaded {
//                Section {
//                    LabeledContent("Size") {
//                        Text(Int64(model.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
//                    }
//                }
//            }
        }
        .listRowBackground(EmptyView())
        .frame(maxWidth: .infinity)
    }
}

/// The model for the metadata view.
@MainActor
protocol OfflineMapAreaMetadata: ObservableObject {
    /// The title of the area.
    var title: String { get }
    /// The thumbnail for the area.
    var thumbnailImage: UIImage? { get async }
    /// The description of the area.
    var description: String { get }
    /// A Boolean value indicating if the area has been downloaded.
    var isDownloaded: Bool { get }
    /// A Boolean value indicating if the area is in a state that allows download.
    var allowsDownload: Bool { get }
    /// The size of the area on disk.
    var directorySize: Int { get }
    
    /// Removes the downloaded area.
    func removeDownloadedArea()
    /// Starts downloading the area.
    func startDownload()
}

extension PreplannedMapModel: OfflineMapAreaMetadata {
    var thumbnailImage: UIImage? {
        get async {
            try? await preplannedMapArea.thumbnail?.load()
            return preplannedMapArea.thumbnail?.image
        }
    }
    var title: String { preplannedMapArea.title }
    var description: String { preplannedMapArea.description }
    var isDownloaded: Bool { status.isDownloaded }
    var allowsDownload: Bool { status.allowsDownload }
    
    func startDownload() {
        Task { await downloadPreplannedMapArea() }
    }
}

extension OnDemandMapModel: OfflineMapAreaMetadata {
    var description: String { "" }
    var isDownloaded: Bool { status.isDownloaded }
    var thumbnailImage: UIImage? { thumbnail }
    var allowsDownload: Bool { false }
    func startDownload() { fatalError() }
}

#Preview {
    OfflineMapAreaMetadataView(model: MockMetadata(), isSelected: false)
}

private class MockMetadata: OfflineMapAreaMetadata {
    var title: String { "Redlands" }
    var thumbnailImage: UIImage? { nil }
    var description: String { "" }
    var isDownloaded: Bool { true }
    var allowsDownload: Bool { true }
    var directorySize: Int { 1_000_000_000 }
    
    func removeDownloadedArea() {}
    func startDownload() {}
}
