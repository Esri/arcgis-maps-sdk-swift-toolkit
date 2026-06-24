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

/// The `FeatureEditor` component allows users to edit geometries in the
/// feature editor.
///
/// **Features**
///
/// - Displays controls for performing common geometry editing actions:
///     - Changing the tool.
///     - Deleting the selected element.
///     - Undoing the last action on the geometry.
///     - Redoing the last undone action.
///     - Configuring snap settings.
/// - Supports styled vertical and horizontal layouts, or no built-in layout or styling.
///
/// **Behavior**
///
/// The toolbar is shown only while the feature editor is editing a geometry.
///
/// By default, the toolbar is displayed in a vertical layout. Pass `nil` for `style` to display
/// the toolbar without built-in layout or styling, so you can show it in a system toolbar or apply
/// your own layout and styling to the controls.
///
/// The settings button is only shown when the geometry editor has snap settings with non-empty
/// source settings.
///
/// **Associated Types**
///
/// - ``Style``
///
/// - Since: 300.1
public struct FeatureEditor: View {
    /// The style to apply to the toolbar's controls.
    private let style: Style?
    /// The geometry editor from the parent feature editor modifier.
    @Environment(\.geometryEditor) private var geometryEditor
    
    /// Creates a feature editor toolbar.
    /// - Parameter style: The style that determines the toolbar's appearance and layout.
    /// A `nil` value displays the toolbar's controls without built-in layout or styling.
    /// - Since: 300.1
    public init(style: Style? = .vertical) {
        self.style = style
    }
    
    public var body: some View {
        GeometryEditorToolbar(
            geometryEditor: geometryEditor,
            style: GeometryEditorToolbar.Style(featureEditorToolbarStyle: style)
        )
        // Only shows snap settings for features in layers.
        .snapSources(.layers)
    }
}

extension FeatureEditor {
    /// A style that determines the appearance and layout of a feature editor toolbar.
    /// - Since: 300.1
    public enum Style {
        /// Displays the toolbar in a styled horizontal layout.
        case horizontal
        /// Displays the toolbar in a styled vertical layout.
        case vertical
    }
}

private extension GeometryEditorToolbar.Style {
    init?(featureEditorToolbarStyle: FeatureEditor.Style?) {
        switch featureEditorToolbarStyle {
        case .horizontal: self = .horizontal
        case .vertical: self = .vertical
        default: return nil
        }
    }
}
