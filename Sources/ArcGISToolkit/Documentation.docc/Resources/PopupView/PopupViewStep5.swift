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
    
    @StateObject private var dataModel = MapDataModel(
        map: makeMap()
    )
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var popup: Popup?
    
    @State private var showPopup = false
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: dataModel.map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint = identifyScreenPoint,
                          let identifyResult = await Result(awaiting: {
                              try await proxy.identifyLayers(
                                screenPoint: identifyScreenPoint,
                                tolerance: 10,
                                returnPopupsOnly: true
                              )
                          })
                        .cancellationToNil()
                    else {
                        return
                    }
                    
                    defer { self.identifyScreenPoint = nil }
                    self.popup = try? identifyResult.get().first?.popups.first
                    self.showPopup = self.popup != nil
                }
        }
    }
}
