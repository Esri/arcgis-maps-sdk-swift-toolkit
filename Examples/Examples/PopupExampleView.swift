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
        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
        
        // Popups example map. - 4 types: text, media image, media chart, fields list
        let portalItem1 = PortalItem(portal: portal, id: Item.ID(rawValue: "10b79e7ad1944422b87f73da86dcf752")!)

        // Popups example map. - Arcade
        //Test Case 3.5 Display popup with expression elements defining media [SDK]
        //https://runtimecoretest.maps.arcgis.com/home/item.html?id=34752f1d149f4b2db96f7a1637767173
        let portalItem2 = PortalItem(portal: portal, id: Item.ID(rawValue: "34752f1d149f4b2db96f7a1637767173")!)

        //Test Case 3.2 Display popup with multiple fields elements [FT-SDK]
        //https://runtimecoretest.maps.arcgis.com/home/item.html?id=8d75d1dbdb5c4ad5849abb26b783987e  **Modified**
        let portalItem3 = PortalItem(portal: portal, id: Item.ID(rawValue: "8d75d1dbdb5c4ad5849abb26b783987e")!)

        //Recreation Map with Attachments.
        //https://runtimecoretest.maps.arcgis.com/home/item.html?id=2afef81236db4eabbbae357e4f990039
        let portalItem4 = PortalItem(portal: portal, id: Item.ID(rawValue: "2afef81236db4eabbbae357e4f990039")!)

        //Recreation Map with Attachments - New
        //https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=79c995874bea47d08aab5a2c85120e7f
        let portalItem5 = PortalItem(portal: portal, id: Item.ID(rawValue: "79c995874bea47d08aab5a2c85120e7f")!)

        //Attachments
        //https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=9e3baeb5dcd4473aa13e0065d7794ca6
        let portalItem6 = PortalItem(portal: portal, id: Item.ID(rawValue: "9e3baeb5dcd4473aa13e0065d7794ca6")!)

        return Map(item: portalItem1)
    }
    
    /// The map displayed in the map view.
    @StateObject private var map = makeMap()
    
    @State private var identifyScreenPoint: CGPoint?
    @State private var identifyResult: Result<[IdentifyLayerResult], Error>?

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
                        else {
                            return
                        }
                        
                        self.identifyResult = identifyResult
                        self.identifyScreenPoint = nil
                    }
                    .overlay(alignment: .topLeading) {
                        Group {
                            if identifyScreenPoint != nil {
                                ProgressView()
                                    .esriBorder()
                            } else if let identifyResult = identifyResult {
                                IdentifyResultView(identifyResult: identifyResult)
                                    .esriBorder()
                            }
                        }
                        .frame(maxWidth: 400)
                        .padding()
                    }
            }
        }
    }
}

struct IdentifyResultView: View {
    var identifyResult: Result<[IdentifyLayerResult], Error>
    
    var body: some View {
        switch identifyResult {
        case .success(let identifyLayerResults):
            // Get the first popup from the first layer result.
            if let popup = identifyLayerResults.first?.popups.first {
                PopupView(popup: popup)
            }
        case .failure(let error):
            Text("Identify error: \(error.localizedDescription).")
        }
    }
}
