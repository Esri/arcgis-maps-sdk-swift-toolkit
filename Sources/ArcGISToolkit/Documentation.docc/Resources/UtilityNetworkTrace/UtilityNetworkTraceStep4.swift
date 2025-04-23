import ArcGIS
import ArcGISToolkit
import SwiftUI

struct UtilityNetworkTraceExampleView: View {
    @State private var activeDetent: FloatingPanelDetent = .half
    
    @State private var map = makeMap()
    
    @State private var mapPoint: Point?
    
    @State private var resultGraphicsOverlay = GraphicsOverlay()
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: map,
                graphicsOverlays: [resultGraphicsOverlay]
            )
            .onSingleTapGesture { _, mapPoint in
                self.mapPoint = mapPoint
            }
            .task {
                do {
                    let publicSample = try await ArcGISCredential.publicSample
                    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample)
                } catch {
                    print("Error creating credential:", error.localizedDescription)
                }
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
                    mapViewProxy: mapViewProxy
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
