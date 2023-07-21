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
            id: Item.ID("415184073d934229b4bf4389d2708683")!
        )
//        let featureLayer = FeatureLayer(item: portalItem)
//        let map = Map(basemapStyle: .arcGISStreets)
//        map.addOperationalLayer(featureLayer)
//        return map
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
//
//                        // You must call `evaluateExpression()` on the popup prior to accessing any properties
//                        try? await self.popup?.evaluateExpressions()
//
//                        // You can then loop through the popup elements, looking for the `TextPopupElement`.
//                        self.popup?.evaluatedElements.forEach { popupElement in
//                            if let textElement = popupElement as? TextPopupElement {
//                                // The `text` property of the `TextPopupElement contains the final formatted string.
//                                // The string is formatted/populated by the call to `evaluateExpressions()`.
//                                print("text: \(textElement.text)")
//                            }
//                        }
                    }
                    .floatingPanel(
                        selectedDetent: $floatingPanelDetent,
                        horizontalAlignment: .leading,
                        isPresented: $showPopup
                    ) {
                        if let popup = popup {
                            PopupView(popup: popup, isPresented: $showPopup)
                                .showCloseButton(true)
                                .padding()
                        }
                    }
//                    .task {
//                        try? await dataModel.map.load()
//                        print("Map load status: \(dataModel.map.loadStatus); error = \(dataModel.map.loadError)")
//                    }
            }
        }
    }
}
