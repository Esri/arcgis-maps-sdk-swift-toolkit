// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import SwiftUI

/// `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
/// on an existing `GeoView`, which shows a representation of the current `visibleArea` (for a `MapView`) or `viewpoint` (for a `SceneView`).
///
/// | MapView | SceneView |
/// | ------- | --------- |
/// | ![OverviewMap - MapView](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/assets/16397058/61415dd8-cdbc-4048-a439-92cf13729e3e) | ![OverviewMap - SceneView](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/assets/16397058/5a201035-c303-48a5-bc95-1324796385ea) |
///
/// > Note: OverviewMap uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.
///
/// **Features**
///
/// - Displays a representation of the current visible area or viewpoint for a connected `GeoView`.
/// - Supports a configurable scaling factor for setting the overview map's zoom level relative to
/// the connected view.
/// - Supports a configurable symbol for visualizing the current visible area or viewpoint
/// representation (a `FillSymbol` for a connected `MapView`; a `MarkerSymbol` for a connected
/// `SceneView`).
/// - Supports using a custom map in the overview map display.
///
/// **Behavior**
///
/// For an `OverviewMap` on a `MapView`, the `MapView`'s `visibleArea` property will be represented in the `OverviewMap` as a polygon, which will rotate as the `MapView` rotates.
///
/// For an `OverviewMap` on a `SceneView`, the center point of the `SceneView`'s `currentViewpoint` property will be represented in the `OverviewMap` by a point.
///
/// To use a custom map in the `OverviewMap`, use the `map` argument in either ``OverviewMap/forMapView(with:visibleArea:map:)`` or ``OverviewMap/forSceneView(with:map:)``.
///
/// To see the `OverviewMap` in action, and for examples of `OverviewMap` customization, check out
/// the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [OverviewMapExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/OverviewMapExampleView.swift)
/// in the project. To learn more about using the `OverviewMap` see the <doc:OverviewMapTutorial>.
public struct OverviewMap: View {
    /// The `Viewpoint` of the main `GeoView`.
    let viewpoint: Viewpoint?
    
    /// The visible area of the main `GeoView`. Not applicable to `SceneView`s.
    let visibleArea: ArcGIS.Polygon?
    
    private var symbol: Symbol
    
    private var scaleFactor = 25.0
    
    /// The data model containing the `Map` displayed in the overview map.
    @StateObject private var dataModel = DataModel()
    
    /// The user-defined map used in the overview map. Defaults to `nil`.
    private let userProvidedMap: Map?
    
    /// The actual map used in the overview map.
    private var effectiveMap: Map {
        userProvidedMap ?? dataModel.defaultMap
    }
    
    /// Creates an `OverviewMap` for use on a `MapView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `MapView` used to update the `OverviewMap` view.
    ///   - visibleArea: Visible area of the main `MapView ` used to display the extent graphic.
    ///   - map: The `Map` displayed in the `OverviewMap`. Defaults to `nil`, in which case
    ///   a map with the `arcGISTopographic` basemap style is used.
    /// - Returns: A new `OverviewMap`.
    public static func forMapView(
        with viewpoint: Viewpoint?,
        visibleArea: ArcGIS.Polygon?,
        map: Map? = nil
    ) -> OverviewMap {
        OverviewMap(
            viewpoint: viewpoint,
            visibleArea: visibleArea,
            symbol: .defaultFill(),
            map: map
        )
    }
    
    /// Creates an `OverviewMap` for use on a `SceneView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `SceneView` used to update the
    /// `OverviewMap` view.
    ///   - map: The `Map` displayed in the `OverviewMap`. Defaults to `nil`, in which case
    ///   a map with the `arcGISTopographic` basemap style is used.
    /// - Returns: A new `OverviewMap`.
    public static func forSceneView(
        with viewpoint: Viewpoint?,
        map: Map? = nil
    ) -> OverviewMap {
        OverviewMap(viewpoint: viewpoint, symbol: .defaultMarker(), map: map)
    }
    
    /// Creates an `OverviewMap`. Used for creating an `OverviewMap` for use on a `MapView`.
    /// - Parameters:
    ///   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
    ///   - visibleArea: Visible area of the main `GeoView` used to display the extent graphic.
    ///   - map: The `Map` displayed in the `OverviewMap`.
    init(
        viewpoint: Viewpoint?,
        visibleArea: ArcGIS.Polygon? = nil,
        symbol: Symbol,
        map: Map?
    ) {
        self.visibleArea = visibleArea
        self.viewpoint = viewpoint
        self.symbol = symbol
        userProvidedMap = map
    }
    
    public var body: some View {
        MapView(
            map: effectiveMap,
            viewpoint: makeOverviewViewpoint(),
            graphicsOverlays: [dataModel.graphicsOverlay]
        )
        .attributionBarHidden(true)
        .interactionModes([])
        .border(
            .black,
            width: 1
        )
        .onAppear {
            dataModel.graphic.geometry = visibleArea
            dataModel.graphic.symbol = symbol
        }
        .onChange(of: visibleArea) { _, visibleArea in
            if let visibleArea = visibleArea {
                dataModel.graphic.geometry = visibleArea
            }
        }
        .onChange(of: viewpoint) { _, viewpoint in
            if visibleArea == nil,
               let viewpoint = viewpoint,
               let point = viewpoint.targetGeometry as? Point {
                dataModel.graphic.geometry = point
            }
        }
        .onChange(of: symbol) { _, symbol in
            dataModel.graphic.symbol = symbol
        }
    }
    
    /// Creates an overview viewpoint based on the observed `viewpoint` center, scale, and `scaleFactor`.
    /// - Returns: The new `Viewpoint`.
    func makeOverviewViewpoint() -> Viewpoint? {
        guard let viewpoint = viewpoint,
              let center = viewpoint.targetGeometry as? Point else { return nil }
        
        return Viewpoint(
            center: center,
            scale: viewpoint.targetScale * scaleFactor
        )
    }
    
    // MARK: Modifiers
    
    /// The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
    /// at the a scale equal to: `viewpoint.targetScale` x `scaleFactor`.
    /// The default value is `25.0`.
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
    /// `SimpleFillSymbol` with a red 1 point width outline; for `SceneView`s, the default is a
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

private extension Symbol {
    /// The default marker symbol.
    static func defaultMarker() -> Symbol {
        return SimpleMarkerSymbol(style: .cross, color: .red, size: 12)
    }
    
    /// The default fill symbol.
    static func defaultFill() -> Symbol {
        return SimpleFillSymbol(
            style: .solid,
            color: .clear,
            outline: SimpleLineSymbol(style: .solid, color: .red, width: 1)
        )
    }
}

private extension OverviewMap {
    @MainActor
    private class DataModel: ObservableObject {
        /// The default `Map` used for display in a `MapView`.
        private(set) lazy var defaultMap = Map(basemapStyle: .arcGISTopographic)
        let graphic: Graphic
        let graphicsOverlay: GraphicsOverlay
        
        init() {
            graphic = Graphic()
            graphicsOverlay = GraphicsOverlay(graphics: [graphic])
        }
    }
}
