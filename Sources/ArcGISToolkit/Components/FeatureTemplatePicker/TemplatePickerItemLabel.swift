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

struct TemplatePickerItemLabel: View {
    let item: TemplatePickerItem
    
    @ScaledMetric(relativeTo: .body) private var maxImageSize = 19.5
    
    var body: some View {
        Label {
            Text(item.template.name)
        } icon: {
            if let image = item.image {
                let size = image.size(max: maxImageSize)
                Image(uiImage: image)
                    .resizable()
                    .frame(width: size.width, height: size.height)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}

private extension UIImage {
    func size(max: Double) -> CGSize {
        if size.width > 0, size.height > 0 {
            let xScale = max / size.width
            let yScale = max / size.height
            let scale = min(xScale, yScale)
            
            let newWidth = size.width * scale
            let newHeight = size.height * scale
            return CGSize(width: newWidth, height: newHeight)
        } else {
            return CGSize(width: max, height: max)
        }
    }
}
