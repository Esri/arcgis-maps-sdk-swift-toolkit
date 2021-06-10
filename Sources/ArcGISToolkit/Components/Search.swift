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
public struct Search: View {    
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
