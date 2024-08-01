import ArcGIS
import ArcGISToolkit
import SwiftUI

struct UtilityNetworkTraceExampleView: View {
    @State private var map = makeMap()
    
    @State private var mapPoint: Point?
    
    @State private var resultGraphicsOverlay = GraphicsOverlay()
    
    @State private var screenPoint: CGPoint?
    
    @State private var viewpoint: Viewpoint?
    
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

private extension ArcGISCredential {
    static var publicSample: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}
