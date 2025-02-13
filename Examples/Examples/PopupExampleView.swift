// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct PopupExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("692cf2ca662d40f48c573b17d9ea38e0")!
//            id: Item.ID("22e3c3cf31af406b9e9e8784ffdd7eda")! // works down one level
//            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: makeMap()
    )
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// The popup to be shown as the result of the layer identify operation.
    @State private var popup: Popup?
    
    /// A Boolean value specifying whether the popup view should be shown or not.
    @State private var showPopup = false
    
    /// The detent value specifying the initial `FloatingPanelDetent`.  Defaults to "full".
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
    var body: some View {
        MapViewReader { proxy in
            VStack {
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
                        
                        self.identifyScreenPoint = nil
                        self.popup = try? identifyResult.get().first?.popups.first
                        self.showPopup = self.popup != nil
                    }
                    .floatingPanel(
                        selectedDetent: $floatingPanelDetent,
                        horizontalAlignment: .leading,
                        isPresented: $showPopup
                    ) {
                        Group {
                            if let popup = popup {
                                PopupView(popup: popup, isPresented: $showPopup)
                                    .showCloseButton(true)
                            }
                        }
                        .padding()
                    }
            }
        }
    }
}
