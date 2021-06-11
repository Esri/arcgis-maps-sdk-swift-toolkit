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

/// OverviewMap is a small, secondary MapView (sometimes called an "inset map"), superimposed on an existing MapView, which shows the visible extent of the main MapView.
public struct OverviewMap: View {
    /// A binding to an optional `MapViewProxy`. When a proxy is
    /// available, the binding will be updated by the view. The proxy is
    /// necessary for accessing `MapView` functionality to get and set viewpoints.
    public var proxy: Binding<MapViewProxy?>
    
    /// The Map displayed in the OverviewMap.
    public var map: Map
    
    /// The fill symbol used to display the main MapView extent.
    /// The default is a transparent SimpleFillSymbol with a red, 1 point width outline.
    public var extentSymbol: FillSymbol
    
    /// The factor to multiply the main GeoView's scale by. The OverviewMap will display
    /// at the product of mainGeoViewScale * scaleFactor. The default is `25.0`.
    public var scaleFactor: Double
    
    /// The geometry of the extent Graphic displaying the main map view's extent. Updating
    /// this property will update the display of the OverviewMap.
    @State private var extentGeometry: Envelope?
    
    /// The viewpoint of the OverviewMap's MapView. Updating
    /// this property will update the display of the OverviewMap.
    @State private var overviewMapViewpoint: Viewpoint?
    
    /// Creates an OverviewMap.
    /// - Parameters:
    ///   - proxy: The binding to an optional MapViewProxy.
    ///   - map: The Map to display in the OverviewMap.
    ///   - extentSymbol: The FillSymbol used to display the main MapView's extent.
    ///   - scaleFactor: The scale factor used to calculate the OverviewMap's scale.
    public init(proxy: Binding<MapViewProxy?>,
                map: Map = Map(basemap: Basemap.topographic()),
                extentSymbol: FillSymbol = SimpleFillSymbol(
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
                        .throttle(for: .seconds(0.25),
                                  scheduler: DispatchQueue.main,
                                  latest: true
                        )
                        .eraseToAnyPublisher() ?? Empty<Void, Never>().eraseToAnyPublisher()
            ) {
                guard let centerAndScaleViewpoint = proxy.wrappedValue?.currentViewpoint(type: .centerAndScale),
                      let boundingGeometryViewpoint = proxy.wrappedValue?.currentViewpoint(type: .boundingGeometry)
                else { return }
                
                if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
                    extentGeometry = newExtent
                }
                
                if let viewpointGeometry = centerAndScaleViewpoint.targetGeometry as? Point {
                    let viewpoint = Viewpoint(center: viewpointGeometry,
                                              scale: centerAndScaleViewpoint.targetScale * scaleFactor)
                    overviewMapViewpoint = viewpoint
                }
            }
        }
    }
}
