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

extension FeatureFormView.AddUtilityAssociationView.TabularFeatureSelectionView {
    struct Row: View {
        /// The feature represented by the row.
        let feature: ArcGISFeature
        
        /// The feature row that was last inspected.
        @Binding var inspectedFeature: InspectedFeature?
        
        /// The feature's symbol
        @State private var image: UIImage?
        
        var body: some View {
            HStack {
                if let image {
                    Image(uiImage: image)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .task {
                            image = try? await (feature.table?.layer as? FeatureLayer)?.renderer?.symbol(for: feature)?.makeSwatch(scale: 1.0)
                        }
                }
                if let objectID = feature.objectID {
                    Text(objectID, format: .number.grouping(.never))
                }
                Spacer()
                Button {
                    inspectedFeature = InspectedFeature(feature: feature)
                } label: {
                    Label {
                        if let objectID = feature.objectID {
                            Text(
                                "Zoom to \(objectID)"
                            )
                        }
                    } icon: {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .labelStyle(.iconOnly)
                    .tint(.secondary)
                }
            }
        }
    }
}
