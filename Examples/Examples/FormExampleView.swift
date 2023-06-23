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

struct FormExampleView: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The `ArcGISFeature` to edit in the form.
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
                    feature = await identifyFeature(with: mapViewProxy)
                }
                .ignoresSafeArea(.keyboard)
                
                // Present a FormView in a native SwiftUI sheet
                .sheet(isPresented: Binding { feature != nil } set: { _ in }) {
                    if #available(iOS 16.4, *) {
                        FormView(map: map, feature: feature!)
                            .padding()
                            .presentationBackground(.thinMaterial)
                            .presentationBackgroundInteraction(.enabled)
                            .presentationDetents([.medium])
                    } else {
                        FormView(map: map, feature: feature!)
                            .padding()
                    }
                }
            
                // Or present a FormView in a Floating Panel (provided via the Toolkit)
//                .floatingPanel(
//                    selectedDetent: .constant(.half),
//                    horizontalAlignment: .leading,
//                    isPresented: Binding { feature != nil } set: { _ in }
//                ) {
//                    Group {
//                        if let feature {
//                            FormView(map: map, feature: feature)
//                                .padding()
//                        }
//                    }
//                }
        }
    }
}

extension FormExampleView {
    /// Identifies features, if any, at the current screen point.
    /// - Parameter proxy: The proxy to use for identification.
    /// - Returns: The first identified feature.
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
        }
        return nil
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: <#URL#>)!
    }
}
