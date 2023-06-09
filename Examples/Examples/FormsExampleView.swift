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
    @State private var isPresented = false
    
    @State private var map = Map(url: .sampleData)!
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    Task {
                        guard let feature = try await mapViewProxy.identify(on: map.operationalLayers.first!, screenPoint: screenPoint, tolerance: 10).geoElements.first as? ArcGISFeature else {
                            isPresented = false
                            return
                        }
                        isPresented = true
                    }
                }
                .floatingPanel(selectedDetent: .constant(.half), horizontalAlignment: .leading, isPresented: $isPresented) {
                    Forms(map: map)
                        .padding()
                }
        }
    }
}

extension URL {
    static var sampleData: Self {
        .init(string: "<#URL#>")!
    }
}
