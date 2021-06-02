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
    public var geoView: MapView
    public var map = Map(basemap: Basemap.topographic())
    public var width: CGFloat = 200.0
    public var height: CGFloat = 132.0
    public var extentSymbol = SimpleFillSymbol(style: .solid,
                                               color: .clear,
                                               outline: SimpleLineSymbol(style: .solid,
                                                                         color: .red,
                                                                         width: 1.0)
    )
    
    @State private var extentGeometry = Envelope(center: Point(x: -9813416.487598, y: 5126112.596989), width: 5000000, height: 10000000)
    
    @State private var overviewViewpoint: Viewpoint = Viewpoint(latitude: 0.0, longitude: 0.0, scale: 100000000000)
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var scale = 10000000.0
    
    public init(geoView: MapView,
                map: Map = Map(basemap: Basemap.topographic()),
                width: CGFloat = 200.0,
                height: CGFloat = 132.0,
                extentSymbol: SimpleFillSymbol = SimpleFillSymbol(style: .solid,
                                                                  color: .clear,
                                                                  outline: SimpleLineSymbol(style: .solid,
                                                                                            color: .red,
                                                                                            width: 1.0))
    ) {
        self.geoView = geoView
        self.map = map
        self.width = width
        self.height = height
        self.extentSymbol = extentSymbol
        
        
        // Ugh.
        // Figure out how to pass in Viewpoint binding to OverviewMap and then do the `onchange` of that.
        // figure out how to set an initial viewpoint on the MapView, although maybe "Binding" is not the correct
        // way to go, since the MapView's viewpoint binding is nil
        //
        // Figure out how to get the publisher stuff working given the fact that we're already hooked
        // into the coreGeoView.viewpointChanged stuff; it's just propagating that out to the client.
        // The issue is that you can't use "subscription", so need a SwiftUI way to do it...
        
        
//        geoView.onChange(of: geoView.viewpoint?.wrappedValue, perform: { (viewpoint) in
//            print("viewpoint changed")
//        })

        geoView.viewpointChangedPublisher.sink(receiveValue: {
//            viewpointDidChange()
            print("wow")
        })
        .store(in: &subscriptions)
    }
    
    // Need to watch for changes to geoView.viewpoint
    // When geoView.viewpoint changes, update overviewViewpoint
    public var body: some View {
        ZStack {
        makeMapView()
            .attributionTextHidden()
            .interactionModes([])
            .frame(width: width, height: height)
            .border(Color.black, width: 1)
            Button("Zoom") {
                extentGeometry = Envelope(center: Point(x: -9813416.487598, y: 5126112.596989), width: 2000000, height: 10000000)
            }
        }
    }
    
    private func makeMapView() -> MapView {
        let extentGraphic = Graphic(geometry: extentGeometry, symbol: extentSymbol)
        return MapView(map: map,
                       viewpoint: $overviewViewpoint,
                       graphicsOverlays: [GraphicsOverlay(graphics: [extentGraphic])]
        )
    }
    
    //Ideally component would take a binding to a viewpoint, use the onchange thing to be notified when it changes.
    
    
    // OverviewMap needs to:
    // - be notified when a geoview's viewpoint changes
    // - be able to get a viewpoint from a geoview (both .centerAndScale and .boundingGeometry)
    // - be able to set a viewpoint on a geoview

    // BasemapGallery needs to:
    // - load a Portal's basemaps
    // - get and display a thumbnail from a basemap's "item" property
    // - set a new basemap on a map/scene contained in a geoview

    // Search needs to:
    // - search using a LocatorTask
    // - support both online and local (MMPK) locators
    // - show suggestions from a LocatorTask
    // - dynamically update list of suggestions as the user types
    // - zoom a map/scene view to a given location and scale
    // - zoom a map/scene view to a given extent
    // - add one or more graphics to a map/scene view
    
    //    TODO:  Look at phil's viewpoint issue and figure out:
    //    - where to put get/set_viewpoint methods
    //    - where to put viewpointChanged publisher (and how)
    
    // Need...
    // - to be notified when a geoview's viewpoint changes
    // - to be able to get a viewpoint from a geoview (either .centerAndScale or .boundingGeometry)
    // - to be able to set a viewpoint on a geoview
    
    // When geoView.viewpoint changes...
    func viewpointDidChange() {
        let centerAndScaleViewpoint = geoView.currentViewpoint(type: .centerAndScale)
        let boundingGeometryViewpoint = geoView.currentViewpoint(type: .boundingGeometry)
        
        if let newExtent = boundingGeometryViewpoint?.targetGeometry as? Envelope {
            extentGeometry = newExtent
        }
        
        if let centerAndScaleViewpoint = centerAndScaleViewpoint {
            overviewViewpoint = Viewpoint(center: centerAndScaleViewpoint.targetGeometry as! Point,
                                                        scale: centerAndScaleViewpoint.targetScale * scale)
        }
    }
}
