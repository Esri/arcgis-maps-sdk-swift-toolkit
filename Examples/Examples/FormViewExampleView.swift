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

struct FormViewExampleView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// A Boolean value indicating whether or not the form is displayed.
    @State private var isPresented = false
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var formViewModel = FormViewModel()
    
    /// The form being edited in the form view.
    @State private var featureForm: FeatureForm?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
                        featureForm = FeatureForm(feature: feature, definition: formDefinition)
                        formViewModel.startEditing(feature)
                        isPresented = featureForm != nil
                    }
                }
                .ignoresSafeArea(.keyboard)
            
                .floatingPanel(
                    selectedDetent: .constant(.half),
                    horizontalAlignment: .leading,
                    isPresented: $isPresented
                ) {
                    FormView(featureForm: featureForm)
                        .padding()
                }
            
                .environmentObject(formViewModel)
                .navigationBarBackButtonHidden(isPresented)
                .toolbar {
                    // Once iOS 16.0 is the minimum supported, the two conditionals to show the
                    // buttons can be merged and hoisted up as the root content of the toolbar.
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isPresented {
                            Button("Cancel", role: .cancel) {
                                formViewModel.undoEdits()
                                isPresented = false
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isPresented {
                            Button("Submit") {
                                Task {
                                    await formViewModel.submitChanges()
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
        }
    }
}

extension FormViewExampleView {
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
        // David
//        .init(string: <#URL#>)!
        
        /// Wind turbines
        /// on: map.operationalLayers.first(where: { $0.name == "windturbine" })!,
//        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=f4cdb74cb4164d68b6b48ca2d4d02dba")!
        
        // Dates
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=ec09090060664cbda8d814e017337837")!
        
        // 0
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=df0f27f83eee41b0afe4b6216f80b541")!
        
        // Form validation
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=5d69e2301ad14ec8a73b568dfc29450a")!
        
        /// Water lines
        /// on: map.operationalLayers.first(where: { $0.name == "CityworksDynamic - Water Hydrants" })!,
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=0f6864ddc35241649e5ad2ee61a3abe4")!
        
        // 1
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=454422bdf7e24fb0ba4ffe0a22f6bf37")!
        
        // 2
//        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=c606b1f345044d71881f99d00583f8f7")!
        
        // 3
//        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=622c4674d6f64114a1de2e0b8382fcf3")!
        
        // 4
//        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=a81d90609e4549479d1f214f28335af2")!
        
        // 5
//        .init(string: "https://runtimecoretest.maps.arcgis.com/home/item.html?id=bb4c5e81740e4e7296943988c78a7ea6")!
        
        /// Text and Date Time form element sanity
        /// Uses publisher1 credentials
//        .init(string: "https://rt-server11.esri.com/portal/apps/mapviewer/index.html?webmap=b6fd63002fcb4ec2b04029440f24d43c")!
        
    // Combo Box
//        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=ed930cf0eb724ea49c6bccd8fd3dd9af")!
        
        // Radio Button
        .init(string: "https://runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=476e9b4180234961809485c8eff83d5d")!
    }
}
