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
@testable import ArcGISToolkit
import SwiftUI

struct ExampleMapView: View {
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    @State private var hasEnabledSourceSettings = false
    @State private var map: Map = {
        let url = URL(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
        let map = Map(url: url)!
        map.loadSettings.featureTilingMode = .enabledWithFullResolutionWhenSupported
        
        let envelope = Envelope(xRange: -9814090 ... -9812210, yRange: 5129650 ... 5130750)
        map.initialViewpoint = Viewpoint(boundingGeometry: envelope)
        
        return map
    }()
    
    private enum ViewState: Equatable {
        case loading, identifying(CGPoint)
    }
    @State private var viewState: ViewState? = .loading
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .contentInsets(featureEditorModel.contentInsets ?? EdgeInsets())
                .geometryEditor(featureEditorModel.geometryEditor)
                .onDrawStatusChanged { drawStatus in
                    // Enables all the snap source settings when the map first completes drawing.
                    guard !hasEnabledSourceSettings,
                          viewState == nil,
                          drawStatus == .completed else {
                        return
                    }
                    
                    featureEditorModel.geometryEditor.enableSnapSourceSettings()
                    hasEnabledSourceSettings = true
                    
                    if _DebugSettings.openFeatureEditor {
                        _DebugSettings.openFeatureEditor = false
                        let screenPoint = mapViewProxy.screenPoint(
                            fromLocation: _DebugSettings.featureEditorIdentifyPoint
                        )!
                        viewState = .identifying(screenPoint)
                    }
                }
                .onSingleTapGesture { screenPoint, _ in
                    guard viewState == nil else { return }
                    viewState = .identifying(screenPoint)
                }
                .overlay(alignment: .topTrailing) {
                    GeometryEditorToolbar(geometryEditor: featureEditorModel.geometryEditor)
                        .padding()
                }
                .task(id: viewState) {
                    guard let viewState else { return }
                    defer { self.viewState = nil }
                    
                    do {
                        switch viewState {
                        case .loading:
                            try await setUpMap()
                        case .identifying(let screenPoint):
                            try await identifyFeature(at: screenPoint, using: mapViewProxy)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
                .task(id: featureEditorModel.viewpoint) {
                    guard let viewpoint = featureEditorModel.viewpoint else { return }
                    await mapViewProxy.setViewpoint(viewpoint, duration: 1)
                }
                .onDisappear {
                    featureEditorModel.featureEditorItem = nil
                }
        }
    }
    
    private func setUpMap() async throws {
        let credential = try await TokenCredential.credential(
            for: map.url!,
            username: "viewer01",
            password: "I68VGU^nMurF"
        )
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        try await map.retryLoad()
    }
    
    private func identifyFeature(at point: CGPoint, using proxy: MapViewProxy) async throws {
        let identifyLayerResults = try await proxy.identifyLayers(
            screenPoint: point,
            tolerance: 10
        )
        let result = identifyLayerResults.first
        let feature = result?.geoElements.first as? ArcGISFeature
        featureEditorModel.featureEditorItem = feature
    }
}

// MARK: - Extensions

private extension GeometryEditor {
    func enableSnapSourceSettings() {
        try? snapSettings.syncSourceSettings()
        snapSettings.isEnabled = true
        
        enableAllSnapSourceSettings(snapSettings.sourceSettings)
    }
    
    private func enableAllSnapSourceSettings(_ sourceSettings: [SnapSourceSettings]) {
        for sourceSetting in sourceSettings {
            sourceSetting.isEnabled = true
            enableAllSnapSourceSettings(sourceSetting.childSourceSettings)
        }
    }
}
