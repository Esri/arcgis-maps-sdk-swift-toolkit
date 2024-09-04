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

struct PreplannedMetadataView: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: PreplannedMapModel
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                if let image = model.preplannedMapArea.thumbnail {
                    HStack {
                        Spacer()
                        LoadableImageView(loadableImage: image)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.vertical, 10)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(model.preplannedMapArea.title)
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if model.preplannedMapArea.description.isEmpty {
                        Text("This area has no description.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text(model.preplannedMapArea.description)
                            .font(.subheadline)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Size")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Int64(model.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
                        .font(.subheadline)
                }
            }
            Section {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .gray.opacity(0.1))
                        .font(.title)
                    Button("Delete Map Area", role: .destructive) {
                        dismiss()
                        model.removeDownloadedPreplannedMapArea()
                        Task {
                            await model.load()
                        }
                    }
                }
            }
        }
        .navigationTitle(model.preplannedMapArea.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .bold()
                }
            }
        }
    }
}

#Preview {
    struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
        var packagingStatus: PreplannedMapArea.PackagingStatus? { .complete }
        var title: String { "Mock Preplanned Map Area" }
        var description: String { "This is the description text" }
        var thumbnail: LoadableImage? { nil }
        
        func retryLoad() async throws { }
        func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
            DownloadPreplannedOfflineMapParameters()
        }
    }
    
    return PreplannedMetadataView(
        model: PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: MockPreplannedMapArea(),
            portalItemID: .init("preview")!,
            preplannedMapAreaID: .init("preview")!
        )
    )
}
