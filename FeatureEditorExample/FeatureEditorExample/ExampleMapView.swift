// Copyright 2026 Esri
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

/// A view for identifying a feature to edit on a map.
struct ExampleMapView: View {
    /// The view model containing objects needed for the feature editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// The map with the features to edit, created from a Naperville Electric web map portal item.
    @State private var map: Map = {
        let url = URL(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
        let map = Map(url: url)!
        
        // Enables full resolution feature tiling to improve snapping accuracy.
        map.loadSettings.featureTilingMode = .enabledWithFullResolutionWhenSupported
        
        let initialExtent = Envelope(xRange: -9815340 ... -9815040, yRange: 5129550 ... 5130070)
        map.initialViewpoint = Viewpoint(boundingGeometry: initialExtent)
        
        return map
    }()
    
    /// The state of the view.
    private enum ViewState: Equatable {
        /// The view is being set up.
        case settingUp
        /// A feature is being identified at the given screen point.
        case identifyingFeature(screenPoint: CGPoint)
    }
    /// The current state of the view, used to trigger asynchronous actions.
    @State private var viewState: ViewState? = .settingUp
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .geometryEditor(featureEditorModel.geometryEditor)
                .onSingleTapGesture { screenPoint, _ in
                    guard viewState == nil else { return }
                    viewState = .identifyingFeature(screenPoint: screenPoint)
                }
                .task(id: viewState) {
                    // Performs an action associated with the current view state.
                    guard let viewState else { return }
                    defer { self.viewState = nil }
                    
                    do {
                        switch viewState {
                        case .settingUp:
                            try await setUp()
                        case .identifyingFeature(let screenPoint):
                            try await editFeature(at: screenPoint, using: mapViewProxy)
                        }
                    } catch {
                        print("Error:", error)
                    }
                }
        }
        .overlay(alignment: .topTrailing) {
            // The toolbar for the feature editor. This needs to be placed
            // below the feature editor modifier in the view hierarchy.
            FeatureEditorToolbar()
                .padding()
        }
        .onDisappear {
            // Dismisses the feature editor when the view disappears.
            featureEditorModel.feature = nil
        }
    }
    
    /// Opens the feature editor with a feature identified at a given screen point.
    /// - Parameters:
    ///   - screenPoint: The point on the screen at which to identify a feature.
    ///   - proxy: The proxy used to identify the feature on the map view.
    private func editFeature(at screenPoint: CGPoint, using proxy: MapViewProxy) async throws {
        let results = try await proxy.identifyLayers(screenPoint: screenPoint, tolerance: 10)
        let firstFeature = results.first?.geoElements.first as? ArcGISFeature
        featureEditorModel.feature = firstFeature
    }
    
    /// Sets up the map and snap settings.
    private func setUp() async throws {
        // Note: Never hardcode login information in a production application.
        // This is done solely for the sake of the example.
        let credential = try await TokenCredential.credential(
            for: map.url!,
            username: "viewer01",
            password: "I68VGU^nMurF"
        )
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        try await map.retryLoad()
        
        // Enables the geometry editor's snap settings and sources.
        let snapSettings = featureEditorModel.geometryEditor.snapSettings
        snapSettings.isEnabled = true
        snapSettings.snapsToGeometryGuides = true
        
        await map.operationalLayers.load()
        try? snapSettings.syncSourceSettings()
        
        for sourceSetting in snapSettings.sourceSettings {
            sourceSetting.isEnabled = true
        }
    }
}
