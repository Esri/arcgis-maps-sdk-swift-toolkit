import SwiftUI
import ArcGIS
import ArcGISToolkit

struct FeatureFormExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    @StateObject private var dataModel = MapDataModel(
        map: makeMap()
    )
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var featureForm: FeatureForm? {
        didSet { showFeatureForm = featureForm != nil }
    }
    
    @State private var showFeatureForm = false
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: dataModel.map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint else { return nil }
                    let identifyResult = try? await proxy.identifyLayers(
                        screenPoint: identifyScreenPoint,
                        tolerance: 10
                    )
                        .first(where: { result in
                            if let feature = result.geoElements.first as? ArcGISFeature,
                               (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
                                return true
                            } else {
                                return false
                            }
                        })
                    
                    if let feature = identifyResult?.geoElements.first as? ArcGISFeature,
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
                        featureForm = FeatureForm(feature: feature, definition: formDefinition)
                    }
                }
        }
    }
}
