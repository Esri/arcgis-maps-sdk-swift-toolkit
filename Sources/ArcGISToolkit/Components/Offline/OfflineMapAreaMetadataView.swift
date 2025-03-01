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
                Section {
                    Text(model.description)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(
                        "Description",
                        bundle: .toolkitModule,
                        comment: "A label for the description of the map area"
                    )
                }
                .textCase(nil)
            }
            
            if model.isDownloaded && !isSelected {
                Section {
                    Button(role: .destructive) {
                        if model.dismissMetadataViewOnDelete {
                            dismiss()
                        }
                        model.removeDownloadedArea()
                    } label: {
                        Text(
                            "Delete Map Area",
                            bundle: .toolkitModule,
                            comment: "A label for a button to delete a map area."
                        )
                    }
                }
            }
            
            if !model.isDownloaded {
                Section {
                    Button {
                        dismiss()
                        model.startDownload()
                    } label: {
                        Text(
                            "Download Map Area",
                            bundle: .toolkitModule,
                            comment: "A label for a button to download a map area."
                        )
                    }
                    .disabled(!model.allowsDownload)
                }
            }
        }
        .task { thumbnailImage = await model.thumbnailImage }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button.done {
                    dismiss()
                }
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
            
            if model.isDownloaded {
                Text(model.directorySizeText)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
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
    /// A Boolean value indicating whether the metadata view should be dismissed when the map area is deleted.
    var dismissMetadataViewOnDelete: Bool { get }
    
    /// Removes the downloaded area.
    func removeDownloadedArea()
    /// Starts downloading the area.
    func startDownload()
}

extension OfflineMapAreaMetadata {
    private var directorySizeMeasurement: Measurement<UnitInformationStorage> {
        Measurement(value: Double(directorySize), unit: .bytes)
    }
    
    var directorySizeText: String {
        .init(
            localized: "Size: \(directorySizeMeasurement, format: .byteCount(style: .file))",
            bundle: .toolkitModule,
            comment: "A label for the file size of the map area."
        )
    }
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
    var dismissMetadataViewOnDelete: Bool { false }
    
    func removeDownloadedArea() {}
    func startDownload() {}
}
