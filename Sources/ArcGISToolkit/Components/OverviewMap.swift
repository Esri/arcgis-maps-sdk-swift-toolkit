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
    
    /// The visible area of the main `GeoView`.  Not applicable to `SceneView`s.
    let visibleArea: Polygon?
    
    private var symbol: Symbol
    
    private var scaleFactor: Double = 25.0
    
    @StateObject
    private var map: Map = Map(basemapStyle: .arcGISTopographic)
    
    /// The `Graphic` displaying the visible area of the main `GeoView`.
    @StateObject
    private var graphic: Graphic
    
    /// The `GraphicsOverlay` used to display the visible area graphic.
    @StateObject
    private var graphicsOverlay: GraphicsOverlay
    
    /// Creates an `OverviewMap` for use on a `MapView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
    ///   - visibleArea: Visible area of the main `GeoView` used to display the extent graphic.
    /// - Returns: A new `OverviewMap`.
    public static func forMapView(
        with viewpoint: Viewpoint?,
        visibleArea: Polygon?
    ) -> OverviewMap {
        return OverviewMap(viewpoint: viewpoint, visibleArea: visibleArea)
    }
    
    /// Creates an `OverviewMap` for use on a `SceneView`.
    /// - Parameter viewpoint: Viewpoint of the main `GeoView` used to update the
    /// `OverviewMap` view.
    /// - Returns: A new `OverviewMap`.
    public static func forSceneView(
        with viewpoint: Viewpoint?
    ) -> OverviewMap {
        return OverviewMap(viewpoint: viewpoint)
    }

    /// Creates an `OverviewMap`. Used for creating an `OverviewMap` for use on a `MapView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
    ///   - visibleArea: Visible area of the main `GeoView` used to display the extent graphic.
    init(viewpoint: Viewpoint?,
                visibleArea: Polygon?
    ) {
        self.visibleArea = visibleArea
        self.viewpoint = viewpoint
        
        self.symbol = .defaultFill
        let graphic = Graphic(symbol: self.symbol)

        // It is necessary to set the graphic and graphicsOverlay this way
        // in order to prevent the main geoview from recreating the
        // graphicsOverlay every draw cycle.  That was causing refresh issues
        // with the graphic during panning/zooming/rotating.
        _graphic = StateObject(wrappedValue: graphic)
        _graphicsOverlay = StateObject(wrappedValue: GraphicsOverlay(graphics: [graphic]))
    }
    
    /// Creates an `OverviewMap`. Used for creating an `OverviewMap` for use on a `SceneView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
    init(viewpoint: Viewpoint?) {
        self.viewpoint = viewpoint
        self.visibleArea = nil
        
        self.symbol = .defaultMarker
        let graphic = Graphic(symbol: self.symbol)

        // It is necessary to set the graphic and graphicsOverlay this way
        // in order to prevent the main geoview from recreating the
        // graphicsOverlay every draw cycle.  That was causing refresh issues
        // with the graphic during panning/zooming/rotating.
        _graphic = StateObject(wrappedValue: graphic)
        _graphicsOverlay = StateObject(wrappedValue: GraphicsOverlay(graphics: [graphic]))
    }
    
    public var body: some View {
        MapView(
            map: map,
            viewpoint: makeOverviewViewpoint(),
            graphicsOverlays: [graphicsOverlay]
        )
            .attributionTextHidden()
            .interactionModes([])
            .border(Color.black, width: 1)
            .onAppear(perform: {
                graphic.symbol = symbol
            })
            .onChange(of: visibleArea, perform: { visibleArea in
                if let visibleArea = visibleArea {
                    graphic.geometry = visibleArea
                }
            })
            .onChange(of: viewpoint, perform: { viewpoint in
                if visibleArea == nil,
                   let viewpoint = viewpoint,
                   let point = viewpoint.targetGeometry as? Point {
                    graphic.geometry = point
                }
            })
            .onChange(of: symbol, perform: {
                graphic.symbol = $0
            })
    }
    
    /// Creates an overview viewpoint based on the observed `viewpoint` center, scale, and `scaleFactor`.
    /// - Returns: The new `Viewpoint`.
    func makeOverviewViewpoint() -> Viewpoint? {
        if let viewpoint = viewpoint,
           let center = viewpoint.targetGeometry as? Point {
            return Viewpoint(
                center: center,
                scale: viewpoint.targetScale * scaleFactor
            )
        } else {
            return nil
        }
    }
    
    // MARK: Modifiers
    
    /// The `Map` displayed in the `OverviewMap`.
    /// - Parameter map: The new map.
    /// - Returns: The `OverviewMap`.
    public func map(_ map: Map) -> OverviewMap {
        var copy = self
        copy._map = StateObject(wrappedValue: map)
        return copy
    }
    
    /// The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
    /// at the a scale equal to: `viewpoint.targetscale` x `scaleFactor.
    /// The default value is 25.0.
    /// - Parameter scaleFactor: The new scale factor.
    /// - Returns: The `OverviewMap`.
    public func scaleFactor(_ scaleFactor: Double) -> OverviewMap {
        var copy = self
        copy.scaleFactor = scaleFactor
        return copy
    }
    
    /// The `Symbol` used to display the main `GeoView` visible area. For `MapView`s, the symbol
    /// should be appropriate for visualizing a polygon, as it will be used to draw the visible area. For
    /// `SceneView`s, the symbol should be appropriate for visualizing a point, as it will be used to
    /// draw the current viewpoint's center. For `MapView`s, the default is a transparent
    /// `SimpleFillSymbol` with a red,1 point width outline; for `SceneView`s, the default is a
    /// red, crosshair `SimpleMarkerSymbol`.
    /// - Parameter symbol: The new symbol.
    /// - Returns: The `OverviewMap`.
    public func symbol(_ symbol: Symbol) -> OverviewMap {
        var copy = self
        copy.symbol = symbol
        return copy
    }
}


// MARK: Extensions

extension Graphic: ObservableObject {}
extension GraphicsOverlay: ObservableObject {}
extension Symbol: ObservableObject {}

private extension Symbol {
    /// The default marker symbol.
    static let defaultMarker: MarkerSymbol = SimpleMarkerSymbol(
        style: .cross,
        color: .red,
        size: 12.0
    )
    
    /// The default fill symbol.
    static let defaultFill: FillSymbol = SimpleFillSymbol(
        style: .solid,
        color: .clear,
        outline: SimpleLineSymbol(
            style: .solid,
            color: .red,
            width: 1.0
        )
    )
}
