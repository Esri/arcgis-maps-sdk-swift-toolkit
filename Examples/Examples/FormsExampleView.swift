// Copyright 2023 Esri.

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
import ArcGISToolkit
import SwiftUI

struct FormsExampleView: View {
    @State private var map = Map(url: .sampleData)!
    
    @State private var feature: ArcGISFeature?
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy) {
                        self.feature = feature
                    } else {
                        feature = nil
                    }
                }
                .floatingPanel(
                    selectedDetent: .constant(.half),
                    horizontalAlignment: .leading,
                    isPresented: Binding { feature != nil } set: { _ in }
                ) {
                    Forms(map: map)
                        .feature(feature)
                        .padding()
                }
                .ignoresSafeArea(.keyboard)
        }
    }
}

extension FormsExampleView {
    func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
        if let screenPoint = identifyScreenPoint,
              let feature = try? await Result(awaiting: {
                  try await proxy.identify(
                    on: map.operationalLayers.first!,
                    screenPoint: screenPoint,
                    tolerance: 10
                  )
              })
            .cancellationToNil()?
            .get()
            .geoElements
            .first as? ArcGISFeature {
            return feature
        } else {
            return nil
        }
    }
}

extension URL {
    static var sampleData: Self {
        .init(string: "<#URL#>")!
    }
}
