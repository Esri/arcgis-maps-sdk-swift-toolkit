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
    
    @State private var map = makeMap()
    
    @StateObject private var model = Model()
    
    var body: some View {
        NavigationStack {
            MapViewReader { mapViewProxy in
                MapView(map: map)
            }
        }
    }
}

@MainActor
class Model: ObservableObject {
    enum State {
        case applyingEdits(FeatureForm)
        case cancellationPending(FeatureForm)
        case editing(FeatureForm)
        case finishingEdits(FeatureForm)
        case generalError(FeatureForm, Text)
        case idle
        case validating(FeatureForm)
    }
}

private extension FeatureForm {
    var featureLayer: FeatureLayer? {
        feature.table?.layer as? FeatureLayer
    }
}
