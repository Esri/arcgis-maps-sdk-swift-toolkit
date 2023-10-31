// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

extension DynamicEntityArcadeCalloutExampleView {
    /// An object that contains map information for the dynamic entity arcade callout example view.
    final class MapInfo {
        let layer: DynamicEntityLayer
        let map: Map
        
        init() {
            layer = DynamicEntityLayer(
                dataSource: ArcGISStreamService(
                    // More sample services can be found here:
                    // https://devtopia.esri.com/runtime/milano/blob/main/References/StreamService/streamServiceList.md#sample-stream-services
                    url: URL(string: "https://realtimegis2016.esri.com:6443/arcgis/rest/services/SandyVehicles/StreamServer")!
                )
            )
            
            layer.trackDisplayProperties.showsPreviousObservations = true
            layer.trackDisplayProperties.showsTrackLine = true
            
            map = Map(basemapStyle: .arcGISOceans)
            map.addOperationalLayer(layer)
            map.initialViewpoint = Viewpoint(boundingGeometry: Envelope.saltLake)
        }
    }
}

private extension Envelope {
     /// An envelope around the Salt Lake City area.
     static let saltLake = Envelope(
         xRange: -12475445.104735145...(-12436309.346470555),
         yRange: 4922143.160533925...4993908.647699355,
         spatialReference: .webMercator
     )
 }

/// A view that shows how to display and show a callout for a dynamic entity layer
/// where the information that you want to display is derived from an arcade expression.
struct DynamicEntityArcadeCalloutExampleView: View {
    /// The map information for this example.
    @State private var mapInfo = MapInfo()
    
    @State private var popup: IdentifiableBox<Popup>?
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: mapInfo.map)
                .onSingleTapGesture { point, _ in
                    Task {
                        guard let result = try? await proxy.identify(
                            on: mapInfo.layer,
                            screenPoint: point,
                            tolerance: 12
                        ) else {
                            return
                        }
                        
                        popup = result.popups.first.map { IdentifiableBox(wrapped: $0) }
                    }
                }
        }
        .task {
            try? await mapInfo.layer.load()
            try? await mapInfo.layer.dataSource.load()
            let pd = PopupDefinition()
            let ds = mapInfo.layer.dataSource as! ArcGISStreamService
            let fields = ds.info!.fields
            let popupFields = fields.map {
                let pf = PopupField()
                pf.fieldName = $0.name
                pf.isVisible = true
                return pf
            }
            pd.addFields(popupFields)
            let element = FieldsPopupElement(fields: popupFields)
            element.title = "fields"
            pd.addElement(element)
            pd.title = "Vehicle"
            mapInfo.layer.popupDefinition = pd
        }
        .sheet(item: $popup) { popup in
            PopupView(popup: popup.wrapped)
                .padding()
        }
    }
}

struct IdentifiableBox<T: AnyObject>: Identifiable {
    let wrapped: T
    
    var id: ObjectIdentifier {
        ObjectIdentifier(wrapped)
    }
}
