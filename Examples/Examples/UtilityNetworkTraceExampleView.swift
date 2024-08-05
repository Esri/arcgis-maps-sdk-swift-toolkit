// Copyright 2022 Esri
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
import ArcGISToolkit
import SwiftUI

/// A demonstration of the utility network trace tool which runs traces on a web map published with
/// a utility network and trace configurations.
struct UtilityNetworkTraceExampleView: View {
    @Environment(\.isPortraitOrientation)
    private var isPortraitOrientation
    
    /// The current detent of the floating panel presenting the trace tool.
    @State private var activeDetent: FloatingPanelDetent = .half
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The map with the utility networks.
    @State private var map = makeMap()
    
    /// Provides the ability to detect tap locations in the context of the map view.
    @State private var mapPoint: Point?
    
    /// A container for graphical trace results.
    @State private var resultGraphicsOverlay = GraphicsOverlay()
    
    /// Provides the ability to detect tap locations in the context of the screen.
    @State private var screenPoint: CGPoint?
    
    /// The map viewpoint used by the `UtilityNetworkTrace` to pan/zoom the map to selected features.
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        GeometryReader { geometryProxy in
            MapViewReader { mapViewProxy in
                MapView(
                    map: map,
                    viewpoint: viewpoint,
                    graphicsOverlays: [resultGraphicsOverlay]
                )
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, mapPoint in
                    self.screenPoint = screenPoint
                    self.mapPoint = mapPoint
                }
                .onViewpointChanged(kind: .centerAndScale) {
                    viewpoint = $0
                }
                .task {
                    let publicSample = try? await ArcGISCredential.publicSample
                    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
                }
                .floatingPanel(
                        attributionBarHeight: attributionBarHeight,
                        backgroundColor: Color(uiColor: .systemGroupedBackground),
                        selectedDetent: $activeDetent,
                        horizontalAlignment: .trailing,
                        isPresented: .constant(true)
                ) {
                    UtilityNetworkTrace(
                        graphicsOverlay: $resultGraphicsOverlay,
                        map: map,
                        mapPoint: $mapPoint,
                        screenPoint: $screenPoint,
                        mapViewProxy: mapViewProxy,
                        viewpoint: $viewpoint
                    )
                    .floatingPanelDetent($activeDetent)
                    // Manually account for a device's bottom safe area when using a Floating Panel.
                    // See also #518.
                    .padding(.bottom, isPortraitOrientation ? geometryProxy.safeAreaInsets.bottom : nil)
                }
            }
        }
    }
    
    /// Makes a map from a portal item.
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        return Map(item: portalItem)
    }
}

private extension ArcGISCredential {
    static var publicSample: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}

private extension EnvironmentValues {
    /// A Boolean value indicating whether this environment has a compact horizontal size class and
    /// a regular vertical size class.
    var isPortraitOrientation: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
}
