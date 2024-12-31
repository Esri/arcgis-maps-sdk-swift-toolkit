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

/// Allows a user to select a feature template and displays
/// the name of the template that was selected.
struct FeatureTemplatePickerExampleView: View {
    static func makeMap() -> Map {
        let map = Map(basemapStyle: .arcGISTopographic)
        let featureTable = ServiceFeatureTable(url: URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
        let featureLayer = FeatureLayer(featureTable: featureTable)
        map.addOperationalLayer(featureLayer)
        return map
    }
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = makeMap()
    
    /// A Boolean value indicating if the feature template picker
    /// is presented.
    @State private var templatePickerIsPresented = false
    
    /// The selection of the feature template picker.
    @State private var selection: FeatureTemplateInfo?
    
    var body: some View {
        MapView(map: map)
            .sheet(isPresented: $templatePickerIsPresented) {
                NavigationStack {
                    FeatureTemplatePicker(
                        geoModel: map,
                        selection: $selection,
                        includeNonCreatableFeatureTemplates: true
                    )
                    .onAppear {
                        // Reset selection when the picker appears.
                        selection = nil
                    }
                    .navigationTitle("Feature Templates")
                }
            }
            .onChange(of: selection) { _ in
                // Dismiss the template picker upon selection.
                if selection != nil {
                    templatePickerIsPresented = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        templatePickerIsPresented = true
                    } label: {
                        Text("Templates")
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                if let selection {
                    HStack {
                        if let image = selection.image {
                            Image(uiImage: image)
                        }
                        Text("\(selection.template.name) Template Selected")
                    }
                    .font(.subheadline)
                }
            }
    }
}
