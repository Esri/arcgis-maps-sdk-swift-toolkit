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
/// The toolbar is visible only while a feature's geometry is being edited.
///
/// **Associated Types**
///
/// - ``ToolbarStyle``
///
/// - Since: 300.1
@available(visionOS, unavailable)
public struct FeatureEditor: View {
    /// A binding to the feature to edit.
    @Binding private var feature: ArcGISFeature?
    /// A geometry editor used to edit the feature's geometry on an associated `MapView`.
    private let geometryEditor: GeometryEditor
    /// The map that `feature` is part of, used to set up rule-based snapping.
    private let map: Map?
    /// A proxy for performing map view operations.
    private let mapViewProxy: MapViewProxy?
    /// The style to apply to the toolbar's controls.
    private let toolbarStyle: ToolbarStyle?
    
    /// The shared feature editor model from the environment.
    @Environment(FeatureEditorModel.self) private var model
    
    /// Creates a feature editor.
    /// - Parameters:
    ///   - feature: A binding to the feature to edit.
    ///   The Feature Editor is displayed when the value is non-`nil`.
    ///   - geometryEditor: A geometry editor used to edit the feature's
    ///   geometry on an associated `MapView`.
    ///   - map: The map that `feature` is part of, used to set up rule-based
    ///   snapping for the geometry editor. If `nil` is passed, or the feature
    ///   is not part of a utility network contained in the map, snapping is
    ///   set up without snap rules.
    ///   - mapViewProxy: A proxy used to set the viewpoint on an associated
    ///   `MapView`.
    ///   - toolbarStyle: The style that determines the toolbar's appearance and
    ///   layout. A `nil` value displays the toolbar's controls without
    ///   built-in layout or styling.
    /// - Since: 300.1
    public init(
        _ feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor,
        map: Map?,
        mapViewProxy: MapViewProxy? = nil,
        toolbarStyle: ToolbarStyle? = .vertical
    ) {
        self._feature = feature
        self.geometryEditor = geometryEditor
        self.map = map
        self.mapViewProxy = mapViewProxy
        self.toolbarStyle = toolbarStyle
    }
    
    /// A collection of object ids used to determine when to start editing.
    /// This updates when the `feature` or `map` instances change.
    private var startEditingIDs: [ObjectIdentifier] {
        let objects: [AnyObject?] = [feature, map]
        return objects.compactMap { $0.map(ObjectIdentifier.init) }
    }
    
    public var body: some View {
        FeatureEditorToolbar(style: toolbarStyle)
            .task(id: ObjectIdentifier(geometryEditor)) {
                model.geometryEditor = geometryEditor
                model.restartGeometryEditor()
                await model.monitorGeometryEditorStreams()
            }
            .task(id: startEditingIDs) {
                if let feature {
                    do {
                        try await model.startEditing(rootFeature: feature, on: map)
                    } catch {
                        Logger.featureEditor.error(
                            "Error starting feature editor: \(error.localizedDescription)"
                        )
                    }
                } else {
                    model.stopEditing()
                }
            }
            .onChange(of: model.isPresented) {
                guard !model.isPresented else { return }
                feature = nil
            }
            .onChange(of: ObjectIdentifier(model.geometryEditor.snapSettings)) {
                model.syncSnapSourceSettings()
            }
            .task(id: model.viewpointGeometry, setViewpoint)
            .onDisappear(perform: model.stopEditing)
    }
    
    /// Sets the viewpoint using `model.viewpointGeometry` and the `mapViewProxy`.
    private func setViewpoint() async {
        guard let viewpointGeometry = model.viewpointGeometry else { return }
        defer { model.viewpointGeometry = nil }
        guard let mapViewProxy else { return }
        
        let expandedGeometry = viewpointGeometry.extent.withBuilder { $0.expand(by: 2) }
        let viewpoint = Viewpoint(boundingGeometry: expandedGeometry)
        await mapViewProxy.setViewpoint(viewpoint, duration: 0.5)
    }
}

extension FeatureEditor {
    /// A style that determines the appearance and layout of a feature editor's toolbar.
    /// - Since: 300.1
    public enum ToolbarStyle {
        /// Displays the toolbar in a styled horizontal layout.
        case horizontal
        /// Displays the toolbar in a styled vertical layout.
        case vertical
    }
}

extension Logger {
    /// A logger for the feature editor component.
    static var featureEditor: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureEditor")
    }
}
