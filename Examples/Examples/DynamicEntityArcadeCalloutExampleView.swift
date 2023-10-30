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
        }
    }
}

/// A view that shows how to display and show a callout for a dynamic entity layer
/// where the information that you want to display is derived from an arcade expression.
struct DynamicEntityArcadeCalloutExampleView: View {
    /// The map information for this example.
    @State private var mapInfo = MapInfo()
    /// The callout placement.
    @State private var placement: CalloutPlacement?
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: mapInfo.map)
                .callout(placement: $placement) { placement in
                    let dynamicEntity = placement.geoElement! as! DynamicEntity
                    VehicleCallout(dynamicEntity: dynamicEntity)
                }
                .onSingleTapGesture { point, _ in
                    Task {
                        guard let result = try? await proxy.identify(on: mapInfo.layer, screenPoint: point, tolerance: 12),
                              let observation = result.geoElements.first as? DynamicEntityObservation,
                              let entity = observation.dynamicEntity
                        else {
                            placement = nil
                            return
                        }
                        withAnimation {
                            placement = .geoElement(entity)
                        }
                    }
                }
        }
    }
}

/// A callout view for showing the details of a dynamic entity vehicle.
struct VehicleCallout: View {
    /// The dynamic entity that represents a vehicle.
    let dynamicEntity: DynamicEntity
    
    /// The name of the vehicle.
    @State private var name: String = ""
    
    /// The location of the vehicle.
    @State private var location: String = ""
    
    /// The heading of the vehicle.
    @State private var heading: Double = .nan
    
    /// The speed of the vehicle.
    @State private var speed: Double = .nan
    
    /// Creates a vehicle callout view.
    /// - Parameter dynamicEntity: The dynamic entity vehicle.
    init(dynamicEntity: DynamicEntity) {
        self.dynamicEntity = dynamicEntity
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 6) {
                Text(name)
                    .bold()
                    .evaluateArcadeExpression("$feature.vehiclename", for: dynamicEntity) { evaluation in
                        name = evaluation.stringValue
                    }
                Text(location)
                    .font(.caption2)
                    .evaluateArcadeExpression(
                        "concatenate(\"(\", Round($feature.point_x,6), \", \", Round($feature.point_y,6), \")\")",
                        for: dynamicEntity
                    ) { evaluation in
                        location = evaluation.stringValue
                    }
            }
            if !speed.isNaN {
                Divider()
                    .frame(maxHeight: 44)
                VStack(spacing: 6) {
                    Text(speed, format: .number.precision(.fractionLength(0)))
                        .bold()
                    Text("MPH")
                        .font(.caption2)
                }
            }
            if !heading.isNaN {
                Divider()
                    .frame(maxHeight: 44)
                VStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle")
                        .rotationEffect(.degrees(heading))
                    let measurement = Measurement<UnitAngle>(value: heading, unit: .degrees).formatted()
                    Text(measurement)
                        .font(.caption2)
                }
            }
        }
        .onReceive(dynamicEntity.changes) { _ in
            // Update heading and speed as they change.
            updateHeadingAndSpeed()
        }
        .onAppear {
            // Show initial heading and speed.
            updateHeadingAndSpeed()
        }
        .padding(10)
        .id(ObjectIdentifier(dynamicEntity))
    }
    
    /// Updates the heading and the speed from the dynamic entity.
    private func updateHeadingAndSpeed() {
        withAnimation {
            heading = dynamicEntity.attributes["heading"] as? Double ?? .nan
        }
        speed = dynamicEntity.attributes["speed"] as? Double ?? .nan
    }
}

extension Result<ArcadeEvaluationResult, Error> {
    /// The evaluation as a string. If the evaluation results in an error, `nil`,
    /// or a type other than a string, then an empty string is returned.
    var stringValue: String {
        ((try? get())?.result(as: .string) as? String) ?? ""
    }
}
