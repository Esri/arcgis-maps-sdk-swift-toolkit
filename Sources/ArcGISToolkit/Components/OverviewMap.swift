//
//  SwiftUIView.swift
//  
// Copyright 2021 Esri.

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
import Combine
import ArcGIS

/// <#Description#>
public struct OverviewMap: View {
    /// <#Description#>
    public var proxy: Binding<MapViewProxy?>

    /// <#Description#>
    public var map: Map

    /// <#Description#>
    public var extentSymbol: SimpleFillSymbol
    
    /// <#Description#>
    public var scaleFactor: Double
    
    /// The geometry of the extent Graphic displaying the main map view's extent.
    @State private var extentGeometry: Envelope?

    @State private var overviewMapViewpoint: Viewpoint?
    
    /// <#Description#>
    /// - Parameters:
    ///   - proxy: <#proxy description#>
    ///   - map: <#map description#>
    ///   - extentSymbol: <#extentSymbol description#>
    public init(proxy: Binding<MapViewProxy?>,
                map: Map = Map(basemap: Basemap.topographic()),
                extentSymbol: SimpleFillSymbol = SimpleFillSymbol(
                    style: .solid,
                    color: .clear,
                    outline: SimpleLineSymbol(
                        style: .solid,
                        color: .red,
                        width: 1.0
                    )
                ),
                scaleFactor: Double = 25.0
    ) {
        self.proxy = proxy
        self.map = map
        self.extentSymbol = extentSymbol
        self.scaleFactor = scaleFactor
    }

    public var body: some View {
        ZStack {
            MapView(map: map,
                    viewpoint: $overviewMapViewpoint,
                    graphicsOverlays: [GraphicsOverlay(graphics: [Graphic(geometry: extentGeometry,
                                                                          symbol: extentSymbol)])]
                    )
                .attributionTextHidden()
                .interactionModes([])
                .border(Color.black, width: 1)
                .onReceive(proxy.wrappedValue?.viewpointChangedPublisher
                            .receive(on: DispatchQueue.main)
                            //
                            // I think "throttle" is what we need here because that does
                            // not reset the timer when a new value is published, whereas
                            // debounce will reset the timer, so if there are multiple
                            // values published that arriver faster than the timeout,
                            // none of them will be sent because the timer gets reset.
                            //
                            // That said, neither of these solve the issue of the
                            // extent rectangle not getting drawn while the user is
                            // panning the map.  The extent rectangle disappears when the user
                            // starts panning and will not reappear until the panning stops.
                            //
//                            .debounce(for: .seconds(0.25),
//                                      scheduler: DispatchQueue.main)
//                            .throttle(for: .seconds(0.25),
//                                      scheduler: DispatchQueue.main,
//                                      latest: true
//                            )
                            .eraseToAnyPublisher() ?? Empty<Void, Never>().eraseToAnyPublisher()
                ) {
                    guard let centerAndScaleViewpoint = proxy.wrappedValue?.currentViewpoint(type: .centerAndScale),
                          centerAndScaleViewpoint.objectType != .unknown,
                          let boundingGeometryViewpoint = proxy.wrappedValue?.currentViewpoint(type: .boundingGeometry),
                          boundingGeometryViewpoint.objectType != .unknown
                    else { return }

                    if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
                        extentGeometry = newExtent
                    }
                    
                    if let viewpointGeometry = centerAndScaleViewpoint.targetGeometry as? Point {
                        let viewpoint = Viewpoint(center: viewpointGeometry,
                                                  scale: centerAndScaleViewpoint.targetScale * scaleFactor)
                        print("overviewMapViewpoint updated")
                        overviewMapViewpoint = viewpoint
                    }
                }
        }
    }
}
