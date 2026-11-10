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
import SwiftUI

internal import os

@available(visionOS, unavailable)
public extension MapView {
    /// Adds a feature editor component for editing and adding features to this
    /// `MapView`'s map.
    ///
    /// For usage and more information, see <doc:FeatureEditor>.
    ///
    /// - Note: This needs to be used within a ``FeatureEditorContainer`` view
    /// to work.
    ///
    /// - Parameter feature: A binding to the feature to edit. The feature
    /// editor starts editing when the value is non-`nil`. When the value is
    /// `nil` and the `MapView`'s map has shared templates, the add features
    /// button is shown on the `MapView`.
    func featureEditor(_ feature: Binding<ArcGISFeature?>) -> some View {
        FeatureEditorMapView(feature: feature, mapView: self)
    }
}

/// A view that adds the feature editor component to a `MapView`.
private struct FeatureEditorMapView: View {
    /// A binding to the feature to edit.
    @Binding var feature: ArcGISFeature?
    /// The map view to add the feature editor to.
    let mapView: MapView
    
    /// The shared feature editor model from the environment.
    @Environment(FeatureEditorModel.self) private var model
    /// The vertical size class of the environment.
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    /// The style to use for the toolbar, taking into account the current
    /// environment.
    var toolbarStyle: FeatureEditorToolbar.Style {
        verticalSizeClass == .compact ? .horizontal : .vertical
    }
    
    var body: some View {
        MapViewReader { mapViewProxy in
            mapView
                .geometryEditor(model.geometryEditorModel.geometryEditor)
                .task(id: model.viewpointGeometry) {
                    await setViewpoint(mapViewProxy: mapViewProxy)
                }
        }
        .overlay(alignment: .topTrailing) {
            FeatureEditorToolbar(style: toolbarStyle)
                .padding()
        }
        .task(model.geometryEditorModel.monitorStreams)
        .task(id: feature.map(ObjectIdentifier.init)) {
            if let feature {
                await model.startEditingFeature(feature)
            } else {
                model.stopEditing()
            }
        }
        .onChange(of: model.state) { oldState, newState in
            guard oldState == .editing, newState == .stopped else { return }
            feature = nil
        }
        .task(id: mapView.map) {
            do {
                try await model.populateSharedTemplates(from: mapView.map)
            } catch {
                Logger.featureEditor.error(
                    "Error populating shared templates: \(error.localizedDescription)"
                )
            }
        }
        .onDisappear(perform: model.stopEditing)
    }
    
    /// Sets the viewpoint using `model.viewpointGeometry`.
    /// - Parameter mapViewProxy: The map view proxy used to set the viewpoint.
    private func setViewpoint(mapViewProxy: MapViewProxy) async {
        guard let viewpointGeometry = model.viewpointGeometry else { return }
        
        let expandedGeometry = viewpointGeometry.extent.withBuilder { $0.expand(by: 2) }
        let viewpoint = Viewpoint(boundingGeometry: expandedGeometry)
        await mapViewProxy.setViewpoint(viewpoint, duration: 0.5)
        
        // Prevents canceling an animation started while this task was running.
        if !Task.isCancelled {
            model.viewpointGeometry = nil
        }
    }
}

extension Logger {
    /// A logger for the feature editor component.
    static var featureEditor: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureEditor")
    }
}
