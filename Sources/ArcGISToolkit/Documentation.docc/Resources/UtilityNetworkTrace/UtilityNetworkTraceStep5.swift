import ArcGIS
import ArcGISToolkit
import SwiftUI

struct UtilityNetworkTraceExampleView: View {
    @State private var map = makeMap()
    
    @State var activeDetent: FloatingPanelDetent = .half
    
    @State var mapPoint: Point?
    
    @State var screenPoint: CGPoint?
    
    @State var resultGraphicsOverlay = GraphicsOverlay()
    
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: map,
                viewpoint: viewpoint,
                graphicsOverlays: [resultGraphicsOverlay]
            )
            .onSingleTapGesture { screenPoint, mapPoint in
                self.screenPoint = screenPoint
                self.mapPoint = mapPoint
            }
            .onViewpointChanged(kind: .centerAndScale) {
                viewpoint = $0
            }
            .task {
                let publicSample = try? await ArcGISCredential.publicSample
                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
            }
            .floatingPanel(
                    backgroundColor: Color(uiColor: .systemGroupedBackground),
                    selectedDetent: $activeDetent,
                    horizontalAlignment: .trailing,
                    isPresented: .constant(true)
            ) {
                UtilityNetworkTrace(
                    graphicsOverlay: $resultGraphicsOverlay,
                    map: map,
                    mapPoint: $mapPoint,
                    screenPoint: $screenPoint,
                    mapViewProxy: mapViewProxy,
                    viewpoint: $viewpoint
                )
                .floatingPanelDetent($activeDetent)
            }
        }
    }
    
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        return Map(item: portalItem)
    }
}
