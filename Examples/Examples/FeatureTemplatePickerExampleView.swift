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
import ArcGISToolkit
import SwiftUI

struct FeatureTemplatePickerExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = makeMap()
    
    @State private var isShowingTemplates = false
    
    @State private var selection: FeatureTemplateInfo?
    
    var body: some View {
        MapView(map: map)
            .sheet(isPresented: $isShowingTemplates) {
                FeatureTemplatePicker(
                    geoModel: map,
                    selection: $selection,
                    includeNonCreatableFeatureTemplates: true
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingTemplates = true
                    } label: {
                        Text("Templates")
                    }
                }
            }
    }
}
