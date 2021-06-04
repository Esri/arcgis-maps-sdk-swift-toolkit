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

public struct OverviewMap: View {
    public var proxy: Binding<MapViewProxy?>?
    public var map = Map(basemap: Basemap.topographic())
    public var width: CGFloat = 200.0
    public var height: CGFloat = 132.0
    public var extentSymbol = SimpleFillSymbol(style: .solid,
                                               color: .clear,
                                               outline: SimpleLineSymbol(style: .solid,
                                                                         color: .red,
                                                                         width: 1.0)
    )
    
    public var scaleFactor = 25.0
    
    /// The geometry of the extent Graphic displaying the main map view's extent.
    @State private var extentGeometry: Envelope?
    
    /// The proxy for the overviewMap's map view.
    private var overviewMapViewProxy: Binding<MapViewProxy?>?

    private var subscriptions = Set<AnyCancellable>()
    
    public init(proxy: Binding<MapViewProxy?>?,
                map: Map = Map(basemap: Basemap.topographic()),
                width: CGFloat = 200.0,
                height: CGFloat = 132.0,
                extentSymbol: SimpleFillSymbol = SimpleFillSymbol(style: .solid,
                                                                  color: .clear,
                                                                  outline: SimpleLineSymbol(style: .solid,
                                                                                            color: .red,
                                                                                            width: 1.0))
    ) {
        self.proxy = proxy
        self.map = map
        self.width = width
        self.height = height
        self.extentSymbol = extentSymbol
        
        self.proxy?.wrappedValue?.viewpointChangedPublisher.sink(receiveValue: {
            guard let centerAndScaleViewpoint = (proxy?.wrappedValue)?.currentViewpoint(type: .centerAndScale),
                  let boundingGeometryViewpoint = (proxy?.wrappedValue)?.currentViewpoint(type: .boundingGeometry)
            else { return }
            
            if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
                extentGeometry = newExtent
            }
            
            (overviewMapViewProxy?.wrappedValue)?.setViewpoint(viewpoint: Viewpoint(center: centerAndScaleViewpoint.targetGeometry as! Point,
                                                                     scale: centerAndScaleViewpoint.targetScale * scaleFactor))
        })
        .store(in: &subscriptions)
    }
    
    public var body: some View {
        ZStack {
            makeMapView()
                .attributionTextHidden()
                .interactionModes([])
                .frame(width: width, height: height)
                .border(Color.black, width: 1)
        }
    }
    
    private func makeMapView() -> MapView {
        let extentGraphic = Graphic(geometry: extentGeometry, symbol: extentSymbol)
        return MapView(map: map,
                       graphicsOverlays: [GraphicsOverlay(graphics: [extentGraphic])],
                       proxy: overviewMapViewProxy
        )
    }
}
