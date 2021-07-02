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

/// `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
/// on an existing `GeoView`, which shows the visible extent of that `GeoView`.
public struct OverviewMap: View {
    /// The `Viewpoint` of the main `GeoView`
    let viewpoint: Viewpoint?
    
    /// The visible area of the main `GeoView`.
    let visibleArea: Polygon?
    
    /// The `Graphic` displaying the visible area of the main `GeoView`.
    @StateObject var graphic: Graphic
    
    /// The `GraphicsOverlay` used to display the visible area graphic.
    @StateObject var graphicsOverlay: GraphicsOverlay
    
    /// The `Map` displayed in the `OverviewMap`.
    @StateObject var map: Map = Map(basemap: .topographic())
    
    /// The `Symbol` used to display the main `GeoView` visible area. For MapViews,
    /// the symbol will be a FillSymbol used to display the GeoView visible area. For SceneViews,
    /// the symbol will be a MarkerSymbol, used to display the current viewpoint's center.
    /// For MapViews, the default is a transparent FillSymbol with a red, 1 point width outline;
    /// for SceneViews, the default is a red, crosshair SimpleMarkerSymbol.
    private(set) var symbol: Symbol?
    
    /// The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
    /// at the a scale equal to: `viewpoint.targetscale` x `scaleFactor.
    private(set) var scaleFactor: Double
    
    private let fillSymbol: FillSymbol = SimpleFillSymbol(
        style: .solid,
        color: .clear,
        outline: SimpleLineSymbol(
            style: .solid,
            color: .red,
            width: 1.0
        )
    )
    
    private let markerSymbol: MarkerSymbol = SimpleMarkerSymbol(style: .cross,
                                                                color: .red,
                                                                size: 16.0
    )
    
    /// Creates an `OverviewMap`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
    ///   - visibleArea: Visible area of the main `GeoView`.
    ///   - extentSymbol: The `FillSymbol` used to display the main `GeoView`'s visible area.
    ///   The default is a transparent `SimpleFillSymbol` with a red, 1 point width outline.
    ///   - scaleFactor: The factor to multiply the main `GeoView`'s scale by.
    ///   The default value is 25.0
    public init(viewpoint: Viewpoint?,
                visibleArea: Polygon? = nil,
                symbol: Symbol? = nil,
                scaleFactor: Double = 25.0
    ) {
        self.visibleArea = visibleArea
        self.scaleFactor = scaleFactor
        
        if symbol == nil {
            self.symbol = visibleArea == nil ? markerSymbol : fillSymbol
        }
        else {
            self.symbol = symbol
        }
        
        let graphic = Graphic(geometry: visibleArea,
                              symbol: symbol)
        
        // It is necessary to set the graphic and graphicsOverlay this way
        // in order to prevent the main geoview from recreating the
        // graphicsOverlay every draw cycle.  That was causing refresh issues
        // with the graphic during panning/zooming/rotating.
        _graphic = StateObject(wrappedValue: graphic)
        _graphicsOverlay = StateObject(wrappedValue: GraphicsOverlay(graphics: [graphic]))
        
        if let viewpoint = viewpoint,
           let center = viewpoint.targetGeometry as? Point {
            self.viewpoint = Viewpoint(center: center,
                                       scale: viewpoint.targetScale * scaleFactor
            )
        }
        else {
            self.viewpoint = nil
        }
    }
    
    public var body: some View {
        MapView(
            map: map,
            viewpoint: viewpoint,
            graphicsOverlays: [graphicsOverlay]
        )
            .attributionTextHidden()
            .interactionModes([])
            .border(Color.black, width: 1)
            .onChange(of: visibleArea, perform: { visibleArea in
                if let visibleArea = visibleArea {
                    graphic.geometry = visibleArea
                    graphic.symbol = symbol != nil ? symbol : fillSymbol
                }
            })
            .onChange(of: viewpoint, perform: { viewpoint in
                if visibleArea == nil,
                   let viewpoint = viewpoint,
                   let point = viewpoint.targetGeometry as? Point {
                    graphic.geometry = point
                    graphic.symbol = symbol != nil ? symbol : markerSymbol
                }
            })
            .onChange(of: symbol, perform: { graphic.symbol = $0 })
    }
    
    public func map(_ map: Map) -> OverviewMap {
        var copy = self
        copy._map = StateObject(wrappedValue: map)
        return copy
    }
}

extension Graphic: ObservableObject {}
extension GraphicsOverlay: ObservableObject {}
