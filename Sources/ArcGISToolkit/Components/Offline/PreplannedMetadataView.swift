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
    
    /// A Boolean value indicating whether the current map area is selected.
    let isSelected: Bool
    
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
                    Text(nameLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(model.preplannedMapArea.title)
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text(descriptionLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if model.preplannedMapArea.description.isEmpty {
                        Text(noDescriptionLabel)
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text(model.preplannedMapArea.description)
                            .font(.subheadline)
                    }
                }
                VStack(alignment: .leading) {
                    Text(sizeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Int64(model.directorySize), format: .byteCount(style: .file, allowedUnits: [.kb, .mb]))
                        .font(.subheadline)
                }
            }
            if !isSelected {
                Section {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .gray.opacity(0.1))
                            .font(.title)
                        Button(deleteLabel, role: .destructive) {
                            dismiss()
                            model.removeDownloadedPreplannedMapArea()
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
                    Text.done
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
        ),
        isSelected: false
    )
}

private extension PreplannedMetadataView {
    var nameLabel: String {
        .init(
            localized: "Name",
            bundle: .toolkitModule,
            comment: "A label for the name of the map area."
        )
    }
    
    var descriptionLabel: String {
        .init(
            localized: "Description",
            bundle: .toolkitModule,
            comment: "A label for the description of the map area."
        )
    }
    
    var noDescriptionLabel: String {
        .init(
            localized: "This area has no description.",
            bundle: .toolkitModule,
            comment: "A label indicating that the map area has no description."
        )
    }
    
    var sizeLabel: String {
        .init(
            localized: "Size",
            bundle: .toolkitModule,
            comment: "A label for the file size of the map area."
        )
    }
    
    var deleteLabel: String {
        .init(
            localized: "Delete Map Area",
            bundle: .toolkitModule,
            comment: "A label for the button to delete a map area."
        )
    }
}
