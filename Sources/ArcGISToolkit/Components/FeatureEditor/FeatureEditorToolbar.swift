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

import SwiftUI

/// The `FeatureEditorToolbar` component allows users to edit geometries in the
/// feature editor.
public struct FeatureEditorToolbar: View {
    /// The style to apply to the toolbar's controls.
    private let style: Style?
    /// The model for the parent feature editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// Creates a feature editor toolbar.
    /// - Parameter style: The style that determines the toolbar's appearance and layout.
    /// A `nil` value displays the toolbar's controls without built-in layout or styling.
    public init(style: Style? = .vertical) {
        self.style = style
    }
    
    public var body: some View {
        GeometryEditorToolbar(
            geometryEditor: featureEditorModel.geometryEditor,
            style: style?.geometryEditorToolbarStyle
        )
        // Only show snap settings for features in layers.
        .snapSourceTypes(types: .layers)
    }
}

extension FeatureEditorToolbar {
    /// A style that determines the appearance and layout of a feature editor toolbar.
    public enum Style {
        /// Displays the toolbar in a styled horizontal layout.
        case horizontal
        /// Displays the toolbar in a styled vertical layout.
        case vertical
    }
}

private extension FeatureEditorToolbar.Style {
    init(featureEditorToolbar: FeatureEditorToolbar.Style) {
        self = switch featureEditorToolbar {
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }
}
