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

import ArcGIS
import SwiftUI

@MainActor
@Observable
final class FeatureFormItem: Hashable {
    let form: FeatureForm
    let templateItem: TemplatePickerItem
    var validationErrorCount: Int
    
    init(feature: ArcGISFeature, templateItem: TemplatePickerItem) {
        self.form = FeatureForm(feature: feature)
        self.templateItem = templateItem
        self.validationErrorCount = form.validationErrors.count
    }
}

@MainActor
@Observable
final class TemplatePickerItem: Hashable {
    let template: SharedTemplate
    let layerID: Int
    private(set) var image: UIImage?
    
    nonisolated init(_ template: SharedTemplate, layerID: Int) {
        self.template = template
        self.layerID = layerID
    }
    
    func loadImage() async throws {
        guard image == nil else { return }
        let swatch = try await template.makeSwatch(layerID: layerID)
        image = swatch.cropTransparentPixels()
    }
    
    nonisolated static func == (lhs: TemplatePickerItem, rhs: TemplatePickerItem) -> Bool {
        return lhs === rhs
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}


// MARK: - Extensions

extension EnvironmentValues {
    @Entry var navigationPath: Binding<NavigationPath>?
}

extension Hashable where Self: AnyObject {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension SharedTemplateSource {
    nonisolated func featureTable(withLayerID layerID: Int) -> ArcGISFeatureTable? {
        return switch self {
        case let serviceGeodatabase as ServiceGeodatabase:
            serviceGeodatabase.table(withLayerID: layerID)
        case let geodatabase as Geodatabase:
            geodatabase.featureTable(withServiceLayerID: layerID)
        default:
            nil
        }
    }
}

private extension UIImage {
    func cropTransparentPixels() -> UIImage? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else {
            return nil
        }
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
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
                let alpha = data[pixelIndex + 3]
                
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
}
