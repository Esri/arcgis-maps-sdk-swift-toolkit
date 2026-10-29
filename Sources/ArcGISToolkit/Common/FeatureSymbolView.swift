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

/// A view that makes and shows a feature's symbol.
struct FeatureSymbolView: View {
    let feature: ArcGISFeature
    
    @ScaledMetric private var maxImageSize: CGFloat
    
    @State private var image: UIImage?
    
    init(feature: ArcGISFeature, maxImageSize: Double = 24) {
        self.feature = feature
        _maxImageSize = .init(wrappedValue: maxImageSize, relativeTo: .body)
    }
    
    var body: some View {
        if let image {
            let size = image.size(max: maxImageSize)
            Image(uiImage: image)
                .resizable()
                .frame(width: size.width, height: size.height)
        } else {
            ProgressView()
                .task {
                    await image = feature.symbol ?? UIImage(systemName: "questionmark.circle")
                }
        }
    }
}
