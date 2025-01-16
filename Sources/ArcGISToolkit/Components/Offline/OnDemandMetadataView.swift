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

struct OnDemandMetadataView: View {
    /// The view model for the preplanned map.
    @ObservedObject var model: OnDemandMapModel
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating whether the current map area is selected.
    let isSelected: Bool
    
    var body: some View {
        Form {
            Section {
                if let area = model.onDemandMapArea as? OfflineOnDemandMapArea,
                   let thumbnail = area.thumbnail {
                    HStack {
                        Spacer()
                        LoadableImageView(loadableImage: thumbnail)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.vertical, 10)
                        Spacer()
                    }
                }
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(model.onDemandMapArea.title)
                        .font(.subheadline)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let area = model.onDemandMapArea as? OfflineOnDemandMapArea,
                       !area.description.isEmpty {
                        Text(area.description)
                            .font(.subheadline)
                        
                    } else {
                        Text("This area has no description.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
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
            if !isSelected {
                Section {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .gray.opacity(0.1))
                            .font(.title)
                        Button("Remove Download", role: .destructive) {
                            dismiss()
                            model.removeDownloadedOnDemandMapArea()
                        }
                    }
                }
            }
        }
        .navigationTitle(model.onDemandMapArea.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
