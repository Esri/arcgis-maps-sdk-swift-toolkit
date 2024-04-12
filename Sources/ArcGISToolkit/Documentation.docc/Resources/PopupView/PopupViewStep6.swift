import SwiftUI
import ArcGIS
import ArcGISToolkit

struct PopupExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    @State private var map = makeMap()
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var popup: Popup? {
        didSet { showPopup = popup != nil }
    }
    
    @State private var showPopup = false
    
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
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
                        tolerance: 10,
                        returnPopupsOnly: true
                    ).first
                    popup = identifyResult?.popups.first
                }
                .floatingPanel(
                    selectedDetent: $floatingPanelDetent,
                    horizontalAlignment: .leading,
                    isPresented: $showPopup
                ) { [popup] in
                    PopupView(popup: popup!, isPresented: $showPopup)
                        .showCloseButton(true)
                        .padding()
                }
        }
    }
}
