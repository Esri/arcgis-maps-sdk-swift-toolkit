import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FeatureFormExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("f72207ac170a40d8992b7a3507b44fad")!
        )
        return Map(item: portalItem)
    }
    
    @State private var featureForm: FeatureForm? {
        didSet { featureFormIsPresented = featureForm != nil }
    }
    
    @State private var featureFormIsPresented = false
    
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var map = makeMap()
    
    @State private var submissionError: Text?
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint else { return }
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
                .floatingPanel(
                    selectedDetent: $floatingPanelDetent,
                    horizontalAlignment: .leading,
                    isPresented: $featureFormIsPresented
                ) {
                    if let featureForm {
                        FeatureFormView(featureForm: featureForm)
                            .padding([.horizontal])
                    }
                }
        }
    }
}
