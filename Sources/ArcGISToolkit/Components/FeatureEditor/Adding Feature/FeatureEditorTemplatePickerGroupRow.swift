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

private extension UIImage {
    /// Returns an image created by removing the transparent pixels around this
    /// image.
    /// - Returns: The cropped image, or `nil` if the receiver cannot be
    /// cropped.
    func croppingTransparentPixels() -> UIImage? {
        guard let cgImage,
              let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data as Data? else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        
        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = ((width * y) + x) * bytesPerPixel
                let alpha = pixelData[pixelIndex + 3]
                
                guard alpha > 0 else { continue } // Non-transparent pixel
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
        
        // No non-transparent pixels found.
        guard minX < maxX, minY < maxY else { return nil }
        
        let newWidth = maxX - minX + 1
        let newHeight = maxY - minY + 1
        let cropRect = CGRect(x: minX, y: minY, width: newWidth, height: newHeight)
        
        guard let croppedImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
    }
    
    /// Returns a size calculated from this size when scaled to fit within a
    /// square.
    /// - Parameter max: The maximum width and height of the scaled size.
    /// - Returns: The scaled size that preserves the receiver's aspect ratio.
    func size(max: Double) -> CGSize {
        guard size.width > 0, size.height > 0 else {
            return CGSize(width: max, height: max)
        }
        
        let xScale = max / size.width
        let yScale = max / size.height
        let scale = min(xScale, yScale)
        
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        return CGSize(width: newWidth, height: newHeight)
    }
}
