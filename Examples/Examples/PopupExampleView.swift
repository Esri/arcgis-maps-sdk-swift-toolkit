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
        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, connection: .anonymous)
        
        // Popups example map. - 4 types: text, media image, media chart, fields list
        let portalItem1 = PortalItem(portal: portal, id: Item.ID(rawValue: "10b79e7ad1944422b87f73da86dcf752")!)
        
        // Popups example map. - Arcade
        // Test Case 3.5 Display popup with expression elements defining media [SDK]
        // https://runtimecoretest.maps.arcgis.com/home/item.html?id=34752f1d149f4b2db96f7a1637767173
        //let portalItem2 = PortalItem(portal: portal, id: Item.ID(rawValue: "34752f1d149f4b2db96f7a1637767173")!)
        
        // Test Case 3.2 Display popup with multiple fields elements [FT-SDK]
        // https://runtimecoretest.maps.arcgis.com/home/item.html?id=8d75d1dbdb5c4ad5849abb26b783987e  **Modified**
        //let portalItem3 = PortalItem(portal: portal, id: Item.ID(rawValue: "8d75d1dbdb5c4ad5849abb26b783987e")!)
        
        // Recreation Map with Attachments.
        // https://runtimecoretest.maps.arcgis.com/home/item.html?id=2afef81236db4eabbbae357e4f990039
        //let portalItem4 = PortalItem(portal: portal, id: Item.ID(rawValue: "2afef81236db4eabbbae357e4f990039")!)
        
        // Recreation Map with Attachments - New
        // https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=79c995874bea47d08aab5a2c85120e7f
        //let portalItem5 = PortalItem(portal: portal, id: Item.ID(rawValue: "79c995874bea47d08aab5a2c85120e7f")!)
        
        // Attachments
        // https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=9e3baeb5dcd4473aa13e0065d7794ca6
        //let portalItem6 = PortalItem(portal: portal, id: Item.ID(rawValue: "9e3baeb5dcd4473aa13e0065d7794ca6")!)
        
        return Map(item: portalItem1)
    }
    
    /// The map displayed in the map view.
    @StateObject private var map = makeMap()
    
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
                MapView(map: map)
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
