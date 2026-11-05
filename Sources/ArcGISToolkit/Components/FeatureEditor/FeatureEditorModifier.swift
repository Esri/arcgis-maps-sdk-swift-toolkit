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
internal import os
import SwiftUI

@available(visionOS, unavailable)
public extension MapView {
    /// Creates a feature editor.
    /// - Parameters:
    ///   - feature: A binding to the feature to edit.
    ///   The Feature Editor is displayed when the value is non-`nil`.
    ///   - geometryEditor: A geometry editor used to edit the feature's
    ///   geometry on an associated `MapView`.
    ///   - map: The map used to query the shared templates shown in the
    ///   template picker.
    func featureEditor(
        _ feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor,
        map: Map
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                feature: feature,
                geometryEditor: geometryEditor,
                map: map
            )
        )
    }
}

/// A feature editing component that provides both the geometry editing via a
/// toolbar and the feature form used to edit attributes and save/discard edits
/// via the `featureEditorInspector()` modifier.
///
/// **Toolbar**
///
/// `FeatureEditor` provides a toolbar for common geometry editing operations,
/// including:
///
/// - Changing the tool.
/// - Deleting the selected element.
/// - Undoing the last action on the geometry.
/// - Redoing the last undone action.
/// - Configuring snap settings.
///
/// The toolbar can be shown with a built-in vertical or horizontal style, or
/// without built-in layout when `toolbarStyle` is `nil`.
///
/// **Feature Form Presentation**
///
/// The inspector form UI is presented by applying `featureEditorInspector()` to
/// an ancestor view. `FeatureEditor` and the inspector share states internally,
/// so updates to the bound feature and geometry editor are reflected in both
/// the toolbar and the feature form.
///
/// **Behavior**
///
/// When no feature is selected, the toolbar includes a button to add features.
/// When a feature is selected, the toolbar includes feature editing controls.
///
/// **Associated Types**
///
/// - ``ToolbarStyle``
///
/// - Since: 300.1
private struct FeatureEditorModifier: ViewModifier {
    /// A binding to the feature to edit.
    @Binding var feature: ArcGISFeature?
    /// A geometry editor used to edit the feature's geometry on an associated `MapView`.
    let geometryEditor: GeometryEditor
    /// The map used to populate shared templates.
    let map: Map
    
    /// The shared feature editor model from the environment.
    @Environment(FeatureEditorModel.self) private var model
    /// The vertical size class of the environment.
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    /// The style to use for the toolbar, taking into account the current
    /// environment.
    var toolbarStyle: FeatureEditorToolbar.Style {
        verticalSizeClass == .compact ? .horizontal : .vertical
    }
    
    public func body(content: Content) -> some View {
        MapViewReader { mapViewProxy in
            content
                .task(id: model.viewpointGeometry) {
                    await setViewpoint(mapViewProxy: mapViewProxy)
                }
        }
        .overlay(alignment: .topTrailing) {
            FeatureEditorToolbar(style: toolbarStyle)
                .padding()
        }
        .task(id: ObjectIdentifier(geometryEditor)) {
            model.geometryEditorModel.geometryEditor = geometryEditor
            await model.restartGeometryEditor()
            await model.geometryEditorModel.monitorStreams()
        }
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
        .onChange(of: ObjectIdentifier(model.geometryEditorModel.geometryEditor.snapSettings)) {
            model.geometryEditorModel.syncSnapSourceSettings()
        }
        .task(id: map) {
            do {
                try await model.populateSharedTemplates(from: map)
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
