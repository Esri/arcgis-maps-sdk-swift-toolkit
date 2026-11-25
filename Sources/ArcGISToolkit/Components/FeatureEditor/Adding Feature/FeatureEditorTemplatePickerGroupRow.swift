// Copyright 2026 Esri
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

/// A row that displays a layer template's name and swatch.
struct FeatureEditorTemplatePickerGroupRow: View {
    /// The layer template represented by the row.
    let layerTemplate: LayerTemplate
    /// The text to emphasize within the layer template's name.
    let searchText: String
    
    /// The maximum width and height of the swatch image.
    @ScaledMetric(relativeTo: .body) private var maxImageSize = 19.5
    
    /// The layer template's swatch image.
    @State private var image: UIImage?
    
    var body: some View {
        Label {
            Text(layerTemplate.name.bolding(searchText))
        } icon: {
            if let image {
                let size = image.size(max: maxImageSize)
                Image(uiImage: image)
                    .resizable()
                    .frame(width: size.width, height: size.height)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
                    .task {
                        guard let swatch = try? await layerTemplate.makeSwatch() else {
                            return
                        }
                        image = swatch.croppingTransparentPixels()
                    }
            }
        }
    }
}
