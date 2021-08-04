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
import ArcGIS

/// `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
/// on an existing `GeoView`, which shows the visible extent of that `GeoView`.
public struct BasemapGallery: View {
    public init(
        basemapGalleryItems: [BasemapGalleryItem] = [],
        selectedBasemapGalleryItem: Binding<BasemapGalleryItem?>
    ) {
        self.basemapGalleryItems = basemapGalleryItems
        self._selectedBasemapGalleryItem = selectedBasemapGalleryItem
    }
    
    public var basemapGalleryItems: [BasemapGalleryItem] = []
    
    @Binding
    public var selectedBasemapGalleryItem: BasemapGalleryItem?
    
    public var body: some View {
        PlainList {
            ForEach(basemapGalleryItems) { basemapGalleryItem in
                BasemapGalleryItemRow(item: basemapGalleryItem)
                    .onTapGesture {
                        selectedBasemapGalleryItem = basemapGalleryItem
                    }
            }
        }
        .esriBorder()
    }
    //        MapView(
    //            map: map,
    //            viewpoint: makeOverviewViewpoint(),
    //            graphicsOverlays: [graphicsOverlay]
    //        )
    //            .attributionText(hidden: true)
    //            .interactionModes([])
    //            .border(.black, width: 1)
    //            .onAppear(perform: {
    //                graphic.symbol = symbol
    //            })
    //            .onChange(of: visibleArea, perform: { visibleArea in
    //                if let visibleArea = visibleArea {
    //                    graphic.geometry = visibleArea
    //                }
    //            })
    //            .onChange(of: viewpoint, perform: { viewpoint in
    //                if visibleArea == nil,
    //                   let viewpoint = viewpoint,
    //                   let point = viewpoint.targetGeometry as? Point {
    //                    graphic.geometry = point
    //                }
    //            })
    //            .onChange(of: symbol, perform: {
    //                graphic.symbol = $0
    //            })
    //    }
    
    // MARK: Modifiers
    //
    //    /// The `Map` displayed in the `OverviewMap`.
    //    /// - Parameter map: The new map.
    //    /// - Returns: The `OverviewMap`.
    //    public func map(_ map: Map) -> OverviewMap {
    //        var copy = self
    //        copy._map = StateObject(wrappedValue: map)
    //        return copy
    //    }
    //
    //    /// The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
    //    /// at the a scale equal to: `viewpoint.targetScale` x `scaleFactor`.
    //    /// The default value is `25.0`.
    //    /// - Parameter scaleFactor: The new scale factor.
    //    /// - Returns: The `OverviewMap`.
    //    public func scaleFactor(_ scaleFactor: Double) -> OverviewMap {
    //        var copy = self
    //        copy.scaleFactor = scaleFactor
    //        return copy
    //    }
    //
    //    /// The `Symbol` used to display the main `GeoView` visible area. For `MapView`s, the symbol
    //    /// should be appropriate for visualizing a polygon, as it will be used to draw the visible area. For
    //    /// `SceneView`s, the symbol should be appropriate for visualizing a point, as it will be used to
    //    /// draw the current viewpoint's center. For `MapView`s, the default is a transparent
    //    /// `SimpleFillSymbol` with a red 1 point width outline; for `SceneView`s, the default is a
    //    /// red, crosshair `SimpleMarkerSymbol`.
    //    /// - Parameter symbol: The new symbol.
    //    /// - Returns: The `OverviewMap`.
    //    public func symbol(_ symbol: Symbol) -> OverviewMap {
    //        var copy = self
    //        copy.symbol = symbol
    //        return copy
    //    }
}

private struct BasemapGalleryItemRow: View {
    var item: BasemapGalleryItem
    var body: some View {
        VStack {
            if let thumbnail = item.thumbnail {
                // TODO: thumbnail will have to be loaded.
                Image(uiImage: thumbnail)
            }
            Text(item.name)
                .font(.footnote)
        }
    }
}

// MARK: Extensions

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
