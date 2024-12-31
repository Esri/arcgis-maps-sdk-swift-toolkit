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
    
    var body: some View {
        MapView(map: map)
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
