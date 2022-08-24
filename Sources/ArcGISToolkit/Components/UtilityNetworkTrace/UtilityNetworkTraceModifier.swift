// Copyright 2022 Esri.

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
import SwiftUI

public extension MapView {
    /// Adds a graphical interface to run pre-configured traces on a map's utility networks.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
    ///   - map: The map containing the utility network(s).
    ///   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
    ///   - viewPoint: Acts as the point of identification for items tapped in the utility network.
    ///   - mapViewProxy: Provides a method of layer identification when starting points are being
    ///   chosen.
    ///   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
    ///   - startingPoints: An optional list of programmatically provided starting points.
    @ViewBuilder func utilityNetworkTrace(
        isPresented: Binding<Bool>,
        graphicsOverlay: Binding<GraphicsOverlay>,
        map: Map,
        mapPoint: Binding<Point?>,
        viewPoint: Binding<CGPoint?>,
        mapViewProxy: Binding<MapViewProxy?>,
        viewpoint: Binding<Viewpoint?>,
        startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
    ) -> some View {
        modifier(
            UtilityNetworkTraceModifier(
                isPresented: isPresented,
                graphicsOverlay: graphicsOverlay,
                map: map,
                mapPoint: mapPoint,
                viewPoint: viewPoint,
                mapViewProxy: mapViewProxy,
                startingPoints: startingPoints,
                viewpoint: viewpoint
            )
        )
    }
}

/// Overlays the provided content with a Floating Panel that contains a Utility Network Trace.
struct UtilityNetworkTraceModifier: ViewModifier {
    /// A Boolean value indicating if the view is presented.
    @Binding var isPresented: Bool
    
    /// The current detent of the floating panel.
    @State var activeDetent: FloatingPanelDetent = .half
    
    /// The graphics overlay to hold generated starting point and trace graphics.
    @Binding var graphicsOverlay: GraphicsOverlay
    
    /// The map containing the utility network(s).
    let map: Map
    
    /// Acts as the point at which newly selected starting point graphics will be created
    @Binding var mapPoint: Point?
    
    /// Acts as the point of identification for items tapped in the utility network.
    @Binding var viewPoint: CGPoint?
    
    /// Provides a method of layer identification when starting points are being chosen.
    @Binding var mapViewProxy: MapViewProxy?
    
    /// An optional list of programmatically provided starting points.
    @Binding var startingPoints: [UtilityNetworkTraceStartingPoint]
    
    /// Allows the utility network trace tool to update the parent map view's viewpoint.
    @Binding var viewpoint: Viewpoint?
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .floatingPanel(
                backgroundColor: Color(uiColor: .systemGroupedBackground),
                detent: $activeDetent,
                horizontalAlignment: .trailing,
                isPresented: $isPresented
            ) {
                UtilityNetworkTrace(
                    activeDetent: $activeDetent,
                    graphicsOverlay: $graphicsOverlay,
                    map: map,
                    mapPoint: $mapPoint,
                    viewPoint: $viewPoint,
                    mapViewProxy: $mapViewProxy,
                    viewpoint: $viewpoint,
                    startingPoints: $startingPoints
                )
            }
    }
}
