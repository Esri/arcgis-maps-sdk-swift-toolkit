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
import ArcGISToolkit

struct OverviewMapExampleView: View {
    enum MapOrScene {
        /// The Example shows a map view.
        case map
        /// The Example shows a scene view.
        case scene
    }
    
    @State
    var mapOrScene: MapOrScene = .map
    
    var body: some View {
        Picker("Map or Scene", selection: $mapOrScene, content: {
            Text("Map").tag(MapOrScene.map)
            Text("Scene").tag(MapOrScene.scene)
        })
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        switch mapOrScene {
        case .map:
            OverviewMapForMapView()
        case .scene:
            OverviewMapForSceneView()
        }
    }
}

struct OverviewMapForMapView: View {
    let map = Map(basemapStyle: .arcGISImagery)
    
    @State
    private var viewpoint: Viewpoint?
    
    @State
    private var visibleArea: ArcGIS.Polygon?
    
    var body: some View {
        MapView(map: map)
            .onViewpointChanged(type: .centerAndScale) { viewpoint = $0 }
            .onVisibleAreaChanged { visibleArea = $0 }
            .overlay(
                OverviewMap(viewpoint: viewpoint,
                            visibleArea: visibleArea
                           )
                // These modifiers show how you can modify the default
                // values used for the symbol, map, and scaleFactor.
//                    .symbol(.customFillSymbol)
//                    .map(.customOverviewMap)
//                    .scaleFactor(15.0)
                    .frame(width: 200, height: 132)
                    .padding(),
                alignment: .topTrailing
            )
    }
}

struct OverviewMapForSceneView: View {
    let scene = Scene(basemapStyle: .arcGISImagery)
    
    @State
    private var viewpoint: Viewpoint?
    
    var body: some View {
        SceneView(scene: scene)
            .onViewpointChanged(type: .centerAndScale) { viewpoint = $0 }
            .overlay(
                OverviewMap(viewpoint: viewpoint)
                // These modifiers show how you can modify the default
                // values used for the symbol, map, and scaleFactor.
//                    .symbol(.customMarkerSymbol)
//                    .map(.customOverviewMap)
//                    .scaleFactor(15.0)
                    .frame(width: 200, height: 132)
                    .padding(),
                alignment: .topTrailing
            )
    }
}

struct OverviewMapExampleView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewMapExampleView()
    }
}

// MARK: Extensions

private extension Symbol {
    /// A custom fill symbol.
    static let customFillSymbol: FillSymbol = SimpleFillSymbol(
        style: .diagonalCross,
        color: .blue,
        outline: SimpleLineSymbol(
            style: .solid,
            color: .blue,
            width: 1.0
        )
    )
    
    /// A custom marker symbol.
    static let customMarkerSymbol: MarkerSymbol = SimpleMarkerSymbol(
        style: .x,
        color: .blue,
        size: 16.0
    )
}

private extension Map {
    /// A custom map for the OverviewMap.
    static let customOverviewMap: Map = Map(basemapStyle: .arcGISDarkGray)
}
