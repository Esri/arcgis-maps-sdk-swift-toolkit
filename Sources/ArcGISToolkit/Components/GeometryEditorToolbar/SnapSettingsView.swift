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

/// A view with controls for configuring `SnapSettings` properties.
struct SnapSettingsView: View {
    /// The snap settings to configure.
    let settings: SnapSettings
    /// The allowed snap source types shown in the source settings list.
    let snapSourceTypes: GeometryEditorToolbar.SnapSourceTypes
    
    /// The view models for the root `SnapSourceSettingsToggle` views in the outline group.
    @State private var rootSourceSettingsModels: [SnapSourceSettingsToggle.Model] = []
    /// A Boolean value indicating whether the settings allow snapping to features and graphics.
    @State private var snapsToFeatures = false
    /// A Boolean value indicating whether the settings allow snapping to geometry guides.
    @State private var snapsToGeometryGuides = false
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle(isOn: $snapsToGeometryGuides) {
                    Text(
                        "Snap to Geometry Guides",
                        bundle: .toolkitModule,
                        comment: """
                                A label for a toggle that enables snapping to geometry guides, which
                                are visual aids that help align geometries during editing.
                                """
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: snapsToGeometryGuides) {
                    settings.snapsToGeometryGuides = snapsToGeometryGuides
                }
                
                Toggle(isOn: $snapsToFeatures.animation()) {
                    Text(
                        "Snap to Features",
                        bundle: .toolkitModule,
                        comment: """
                                A label for a toggle that enables snapping to features and graphics,
                                which allows vertices and edges of existing features to be snapped to.
                                """
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: snapsToFeatures) {
                    settings.snapsToFeatures = snapsToFeatures
                }
                
                if snapsToFeatures {
                    Section {
                        OutlineGroup(rootSourceSettingsModels, children: \.children) { model in
                            SnapSourceSettingsToggle(model: model)
                        }
                    } header: {
                        Text(
                            "Snap Sources",
                            bundle: .toolkitModule,
                            comment: """
                                    A title for a list section containing toggles for controlling
                                    the sources that can be snapped to.
                                    """
                        )
                    }
                }
            }
            .onChange(of: ObjectIdentifier(settings), initial: true) {
                // Only allows certain snap sources.
                rootSourceSettingsModels = settings.sourceSettings
                    .filter { snapSourceTypes.contains(source: $0.source) }
                    .map(SnapSourceSettingsToggle.Model.init(settings:))
                
                // Disable snapping on other snap sources that aren't exposed
                // in the UI to avoid confusion.
                settings.sourceSettings
                    .filter { !snapSourceTypes.contains(source: $0.source) }
                    .forEach { $0.isEnabled = false }
                
                // Sets up view's state properties using settings' property values.
                snapsToFeatures = settings.snapsToFeatures
                snapsToGeometryGuides = settings.snapsToGeometryGuides
            }
            .navigationTitle(
                Text(
                    "Snap Settings",
                    bundle: .toolkitModule,
                    comment: """
                        A title of a view containing settings for configuring geometry editor
                        snapping.
                        """
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton(kind: .close)
                }
            }
        }
    }
}

/// A toggle for enabling `SnapSourceSettings`.
private struct SnapSourceSettingsToggle: View {
    /// The model for the view, which contains the settings to enable.
    @Bindable var model: Model
    
    var body: some View {
        Toggle(isOn: $model.isOn) {
            Text(sourceLabel)
            
            switch model.settings.ruleBehavior {
            case .rulesLimitSnapping:
                Text(
                    "Rules limit snapping.",
                    bundle: .toolkitModule,
                    comment: """
                        A label indicating snapping is limited by snap rules, which are constraints
                        that restrict where snapping can occur.
                        """
                )
                .foregroundStyle(.orange)
            case .rulesPreventSnapping:
                Text(
                    "Rules prevent snapping.",
                    bundle: .toolkitModule,
                    comment: """
                        A label indicating snapping is prevented by snap rules, which are
                        constraints that restrict where snapping can occur.
                        """
                )
                .foregroundStyle(.red)
            default:
                EmptyView()
            }
        }
        .disabled(model.isDisabled)
    }
    
    /// A human-readable label for the settings' source.
    private var sourceLabel: String {
        let source = model.settings.source
        let name: String? = switch source {
        case let layer as LayerContent:
            layer.name
        case let overlay as GraphicsOverlay:
            overlay.id
        default:
            nil
        }
        
        if let name, !name.isEmpty {
            return name
        } else {
            return "\(type(of: source))"
        }
    }
}

private extension SnapSourceSettingsToggle {
    /// A view model for a `SnapSourceSettingsToggle`.
    @Observable
    final class Model: Identifiable {
        /// The snap source settings that the toggle enables.
        let settings: SnapSourceSettings
        /// The model's children, one for each of the settings' `childSourceSettings`.
        ///
        /// This is `nil` when `childSourceSettings` is empty to prevent the
        /// parent outline group from showing disclosure chevrons on leaf nodes.
        let children: [Model]?
        
        /// A Boolean value indicating whether the toggle is on.
        ///
        /// This is `true` when snapping is enabled on the `settings`.
        var isOn: Bool {
            didSet { settings.isEnabled = isOn }
        }
        /// A Boolean value indicating whether the toggle is disabled.
        ///
        /// This is `true` when the parent toggle is off or if snapping is
        /// prevented by the settings' `ruleBehavior`.
        var isDisabled: Bool {
            parent?.isOn == false || settings.ruleBehavior == .rulesPreventSnapping
        }
        
        /// The model's parent in the model tree.
        ///
        /// This is `nil` for a model representing a root `SnapSourceSettings`.
        private weak var parent: Model?
        
        init(settings: SnapSourceSettings) {
            self.settings = settings
            self.isOn = settings.isEnabled
            
            if !settings.childSourceSettings.isEmpty {
                let children = settings.childSourceSettings.map(Model.init(settings:))
                self.children = children
                
                for child in children {
                    child.parent = self
                }
            } else {
                self.children = nil
            }
        }
    }
}

#Preview {
    SnapSettingsView(settings: SnapSettings(), snapSourceTypes: .all)
}
