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
/// The toolbar is visible only while a feature's geometry is being edited. The
/// snap settings button is shown only when the geometry editor has non-empty
/// snap source settings.
///
/// **Associated Types**
///
/// - ``ToolbarStyle``
///
/// - Since: 300.1
public struct FeatureEditor: View {
    /// The style to apply to the toolbar's controls.
    private let toolbarStyle: ToolbarStyle?
    /// A binding to the feature to edit.
    @Binding private var feature: ArcGISFeature?
    /// A geometry editor used to edit the feature's geometry on an associated `MapView`.
    private let geometryEditor: GeometryEditor
    /// The shared feature editor model from the environment.
    @Environment(FeatureEditorModel.self) private var model
    
    /// Creates a feature editor.
    /// - Parameters:
    ///   - feature: A binding to the feature to edit.
    ///   The Feature Editor is displayed when the value is non-`nil`.
    ///   - geometryEditor: A geometry editor used to edit the feature's
    ///   geometry on an associated `MapView`.
    ///   - toolbarStyle: The style that determines the toolbar's appearance and
    ///   layout. A `nil` value displays the toolbar's controls without
    ///   built-in layout or styling.
    /// - Since: 300.1
    public init(
        _ feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor,
        toolbarStyle: ToolbarStyle? = .vertical
    ) {
        self._feature = feature
        self.geometryEditor = geometryEditor
        self.toolbarStyle = toolbarStyle
    }
    
    public var body: some View {
        GeometryEditorToolbar(style: toolbarStyle)
            .onChange(of: feature.map(ObjectIdentifier.init), initial: true) {
                model.feature = feature
            }
            .onChange(of: model.feature.map(ObjectIdentifier.init)) {
                feature = model.feature
            }
            .task(id: ObjectIdentifier(geometryEditor)) {
                model.geometryEditor = geometryEditor
                for await isStarted in geometryEditor.$isStarted {
                    model.isEditingGeometry = isStarted
                }
            }
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
