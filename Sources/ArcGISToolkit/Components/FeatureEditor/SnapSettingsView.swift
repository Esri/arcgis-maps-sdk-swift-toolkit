// Copyright 2025 Esri
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

/// A view contain controls for configuring given `SnapSettings`.
///
/// - Note: The snap settings should be synchronized if needed before displaying this view.
struct SnapSettingsView: View {
    /// The snap settings to configure.
    let settings: SnapSettings
    
    /// A Boolean value indicating whether the feature snapping disclosure group is expanded.
    @State private var featureSnappingIsExpanded = false
    /// A Boolean value indicating whether the settings have haptic feedback enabled.
    @State private var hapticFeedbackIsEnabled = false
    /// A Boolean value indicating whether the settings are enabled.
    @State private var isEnabled = false
    /// A Boolean value indicating whether the settings allow snapping to features.
    @State private var snapsToFeatures = false
    /// A Boolean value indicating whether the settings allow snapping to geometry guides.
    @State private var snapsToGeometryGuides = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Snapping", isOn: $isEnabled)
                    .onChange(of: isEnabled) {
                        settings.isEnabled = isEnabled
                    }
            }
            
            Group {
                Section {
                    Toggle("Haptics", isOn: $hapticFeedbackIsEnabled)
                        .onChange(of: hapticFeedbackIsEnabled) {
                            settings.hapticFeedbackIsEnabled = hapticFeedbackIsEnabled
                        }
                    Toggle("Guide Snapping", isOn: $snapsToGeometryGuides)
                        .onChange(of: snapsToGeometryGuides) {
                            settings.snapsToGeometryGuides = snapsToGeometryGuides
                        }
                }
                
                Section {
                    DisclosureGroup(isExpanded: $featureSnappingIsExpanded) {
                        ForEach(settings.sourceSettings, id: \.objectIdentifier) { sourceSettings in
                            SnapSourceSettingsView(settings: sourceSettings)
                        }
                        .disabled(!snapsToFeatures)
                    } label: {
                        Toggle("Feature Snapping", isOn: $snapsToFeatures)
                            .onChange(of: snapsToFeatures) {
                                settings.snapsToFeatures = snapsToFeatures
                                
                                // Expands/collapses the group when the toggle is used.
                                withAnimation {
                                    featureSnappingIsExpanded = snapsToFeatures
                                }
                            }
                    }
                }
            }
            .disabled(!isEnabled)
        }
        .onChange(of: ObjectIdentifier(settings), initial: true) {
            // Sets the state properties to the settings' property values when the object changes.
            featureSnappingIsExpanded = settings.isEnabled
            hapticFeedbackIsEnabled = settings.hapticFeedbackIsEnabled
            isEnabled = settings.isEnabled
            snapsToFeatures = settings.snapsToFeatures
            snapsToGeometryGuides = settings.snapsToGeometryGuides
        }
    }
}

/// A view for displaying and enabling a `SnapSourceSettings` instance and its children.
private struct SnapSourceSettingsView: View {
    /// The snap source settings to display
    let settings: SnapSourceSettings
    
    /// A Boolean value indicating whether the child source settings disclosure group is expanded.
    @State private var childrenGroupIsExpanded = false
    /// A Boolean value indicating whether the snap source settings is enabled.
    @State private var isEnabled = false
    /// The snap source settings' rule behavior.
    @State private var ruleBehavior: SnapRuleBehavior?
    
    var body: some View {
        Group {
            if settings.childSourceSettings.isEmpty {
                HStack {
                    settingsToggle
                    
                    // This aligns the trailing edges of the toggles without children
                    // with those that have a disclosure group chevron.
                    // It also adapts to dynamic type changes automatically.
                    Image(systemName: "chevron.right")
                        .font(.caption2.bold())
                        .opacity(0)
                }
            } else {
                DisclosureGroup(isExpanded: $childrenGroupIsExpanded) {
                    ForEach(settings.childSourceSettings, id: \.objectIdentifier) { settings in
                        SnapSourceSettingsView(settings: settings)
                    }
                    .disabled(!isEnabled)
                } label: {
                    settingsToggle
                }
            }
        }
        .onChange(of: ObjectIdentifier(settings), initial: true) {
            isEnabled = settings.isEnabled
            ruleBehavior = settings.ruleBehavior
            
            guard !settings.childSourceSettings.isEmpty else { return }
            childrenGroupIsExpanded = isEnabled
        }
    }
    
    /// A toggle for enabling and disabling a given snap source settings.
    private var settingsToggle: some View {
        Toggle(isOn: $isEnabled) {
            Text(settings.source.label)
            
            if let ruleBehavior {
                Label(
                    ruleBehavior == .rulesLimitSnapping
                    ? "Snap rules limit snapping."
                    : "Snap rules prevent snapping.",
                    systemImage: "exclamationmark.triangle"
                )
                .foregroundStyle(ruleBehavior == .rulesLimitSnapping ? .orange : .red)
                .font(.caption)
            }
        }
        .disabled(ruleBehavior == .rulesPreventSnapping)
        .onChange(of: isEnabled) {
            settings.isEnabled = isEnabled
            
            // Expands/collapses the group when the toggle is used.
            guard !settings.childSourceSettings.isEmpty else { return }
            withAnimation {
                childrenGroupIsExpanded = isEnabled
            }
        }
    }
}

private extension SnapSource {
    /// A human-readable label for the snap source.
    var label: String {
        switch self {
        case let layer as LayerContent:
            layer.name
        case let overlay as GraphicsOverlay:
            overlay.id
        default:
            "Unknown"
        }
    }
}

private extension SnapSourceSettings {
    /// A unique identifier for the object.
    var objectIdentifier: ObjectIdentifier { ObjectIdentifier(self) }
}
