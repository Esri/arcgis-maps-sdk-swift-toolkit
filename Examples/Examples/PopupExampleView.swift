// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct PopupExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("9f3a674e998f461580006e626611f9ad")!
        )
        return Map(item: portalItem)
    }
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = makeMap()
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// The popup to be shown as the result of the layer identify operation.
    @State private var popup: Popup? {
        didSet { showPopup = popup != nil }
    }
    
    /// A Boolean value specifying whether the popup view should be shown or not.
    @State private var showPopup = false
    
    /// The detent value specifying the initial `FloatingPanelDetent`.  Defaults to "full".
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
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
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $floatingPanelDetent,
                    horizontalAlignment: .leading,
                    isPresented: $showPopup
                ) { [popup] in
                    PopupView(popup: popup!, isPresented: $showPopup)
                        .padding()
                }
        }
    }
}
