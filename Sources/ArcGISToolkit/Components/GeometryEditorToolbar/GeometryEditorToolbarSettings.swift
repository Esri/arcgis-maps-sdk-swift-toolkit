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

/// A view containing settings for a `GeometryEditorToolbar`.
struct GeometryEditorToolbarSettings: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SnapSettingsView(settings: model.geometryEditor.snapSettings)
                } header: {
                    Text(
                        "Snapping",
                        bundle: .toolkitModule,
                        comment: """
                            A header for a list section that contains settings for configuring
                            geometry editor snapping, which automatically adjusts edit positions
                            to guides or nearby geometries.
                            """
                    )
                }
            }
            .navigationTitle(
                Text(
                    "Toolbar Settings",
                    bundle: .toolkitModule,
                    comment: "The title of a view showing settings for a geometry editor toolbar."
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

/// A view with controls for configuring `SnapSettings` properties.
private struct SnapSettingsView: View {
    /// The snap settings to configure.
    let settings: SnapSettings
    
    /// A Boolean value indicating whether the feature snapping disclosure group is expanded.
    @State private var featureSnappingGroupIsExpanded = false
    /// A Boolean value indicating whether the settings have haptic feedback enabled.
    @State private var hapticFeedbackIsEnabled = false
    /// A Boolean value indicating whether the settings are enabled.
    @State private var isEnabled = false
    /// The view models for the root `SnapSourceSettingsToggle` views in the outline group.
    @State private var rootSourceSettingsModels: [SnapSourceSettingsToggle.Model] = []
    /// A Boolean value indicating whether the settings allow snapping to features.
    @State private var snapsToFeatures = false
    /// A Boolean value indicating whether the settings allow snapping to geometry guides.
    @State private var snapsToGeometryGuides = false
    
    var body: some View {
        Toggle(isOn: $isEnabled) {
            Text(
                "Enable Snapping",
                bundle: .toolkitModule,
                comment: """
                    A label for a toggle that enables geometry editor snapping, which allows edit
                    positions to automatically adjust to guides or nearby geometries.
                    """
            )
        }
        .animation(.default, value: isEnabled)
        .onChange(of: isEnabled) {
            settings.isEnabled = isEnabled
        }
        .onChange(of: ObjectIdentifier(settings), initial: true) {
            // Sets up view's state properties using settings' property values.
            featureSnappingGroupIsExpanded = settings.isEnabled
            hapticFeedbackIsEnabled = settings.hapticFeedbackIsEnabled
            isEnabled = settings.isEnabled
            rootSourceSettingsModels = settings.sourceSettings.map(
                SnapSourceSettingsToggle.Model.init(settings:)
            )
            snapsToFeatures = settings.snapsToFeatures
            snapsToGeometryGuides = settings.snapsToGeometryGuides
        }
        
        if isEnabled {
            Toggle(isOn: $hapticFeedbackIsEnabled) {
                Text(
                    "Haptic Feedback",
                    bundle: .toolkitModule,
                    comment: """
                        A label for a toggle that enables haptics, which provides tactile feedback 
                        when the geometry editor snaps.
                        """
                )
            }
            .onChange(of: hapticFeedbackIsEnabled) {
                settings.hapticFeedbackIsEnabled = hapticFeedbackIsEnabled
            }
            
            Toggle(isOn: $snapsToGeometryGuides) {
                Text(
                    "Snap to Geometry Guides",
                    bundle: .toolkitModule,
                    comment: """
                        A label for a toggle that enables snapping to geometry guides, which are 
                        visual aids that help align geometries during editing.
                        """
                )
            }
            .onChange(of: snapsToGeometryGuides) {
                settings.snapsToGeometryGuides = snapsToGeometryGuides
            }
            
            if !rootSourceSettingsModels.isEmpty {
                DisclosureGroup(isExpanded: $featureSnappingGroupIsExpanded) {
                    OutlineGroup(rootSourceSettingsModels, children: \.children) { model in
                        SnapSourceSettingsToggle(model: model)
                    }
                    .disabled(!snapsToFeatures)
                } label: {
                    Toggle(isOn: $snapsToFeatures) {
                        Text(
                            "Snap to Features",
                            bundle: .toolkitModule,
                            comment: """
                                A label for a toggle that enables snapping to features, which allows
                                vertices and edges of existing features to be snapped to.
                                """
                        )
                    }
                    .onChange(of: snapsToFeatures) {
                        settings.snapsToFeatures = snapsToFeatures
                        
                        // Expands/collapses the disclosure group when the toggle is used.
                        withAnimation {
                            featureSnappingGroupIsExpanded = snapsToFeatures
                        }
                    }
                }
            }
        }
    }
}

/// A toggle for enabling a `SnapSourceSettings` instance.
private struct SnapSourceSettingsToggle: View {
    /// The view model for the toggle containing the `SnapSourceSettings`.
    @Bindable var model: Model
    
    var body: some View {
        Toggle(isOn: $model.isOn) {
            Text(model.settings.source.label)
            
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
        .disabled(model.isDisabled || model.settings.ruleBehavior == .rulesPreventSnapping)
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
        /// This is `true` when the parent toggle is off.
        var isDisabled: Bool {
            parent?.isOn == false
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

// MARK: - Helper Extensions

private extension SnapSource {
    /// A human-readable label for the snap source.
    var label: String {
        let name: String? = switch self {
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
            return "\(type(of: self))"
        }
    }
}

#Preview {
    GeometryEditorToolbarSettings()
        .environment(GeometryEditorToolbarModel(geometryEditor: GeometryEditor()))
}
