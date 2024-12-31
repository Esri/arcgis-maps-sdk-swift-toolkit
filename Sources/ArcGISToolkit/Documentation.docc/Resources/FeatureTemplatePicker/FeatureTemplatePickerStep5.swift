import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FeatureTemplatePickerExampleView: View {
    /// Creates a map with a feature table that has templates.
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
                guard let selection else { return }
                
                // Dismiss the template picker upon selection.
                templatePickerIsPresented = false
                
                // Print out selected template name.
                print("\(selection.template.name) Template Selected")
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
    }
}
