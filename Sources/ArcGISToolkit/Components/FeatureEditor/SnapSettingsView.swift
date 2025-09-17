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

@MainActor
@Observable
class SnapSettingsModel {
    private let snapSettings: SnapSettings
    fileprivate let sourceSettings: [SnapSourceSettingsModel]
    
    init(snapSettings: SnapSettings) {        
        self.snapSettings = snapSettings
        
        // Grab the settings from the snapSettings object.
        snapsToFeatures = snapSettings.snapsToFeatures
        snapsToGeometryGuides = snapSettings.snapsToGeometryGuides
        hapticFeedbackIsEnabled = snapSettings.hapticFeedbackIsEnabled
        
        sourceSettings = snapSettings.sourceSettings
            .filter { !($0.source is GraphicsOverlay) }
            .map(SnapSourceSettingsModel.init(sourceSettings:))
    }
    
    var hapticFeedbackIsEnabled: Bool {
        didSet {
            snapSettings.hapticFeedbackIsEnabled = hapticFeedbackIsEnabled
        }
    }
    
    var snapsToFeatures: Bool {
        didSet {
            snapSettings.snapsToFeatures = snapsToFeatures
        }
    }
    
    var snapsToGeometryGuides: Bool {
        didSet {
            snapSettings.snapsToGeometryGuides = snapsToGeometryGuides
        }
    }
}

@MainActor
@Observable
private class SnapSourceSettingsModel: Identifiable {
    private let sourceSettings: SnapSourceSettings
    
    init(sourceSettings: SnapSourceSettings) {
        self.sourceSettings = sourceSettings
        isEnabled = sourceSettings.isEnabled
    }
    
    var isEnabled: Bool {
        didSet {
            sourceSettings.isEnabled = isEnabled
        }
    }
    
    var name: String {
        sourceSettings.source.name
    }
    
    nonisolated var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

struct SnapSettingsView: View {
    @State var model: SnapSettingsModel
    
    var body: some View {
        List {
            Section {
                Toggle("Haptics", isOn: $model.hapticFeedbackIsEnabled)
                Toggle("Guide Snapping", isOn: $model.snapsToGeometryGuides)
            }
            
            Section {
                Toggle("Feature Snapping", isOn: $model.snapsToFeatures)
                
                if model.snapsToFeatures {
                    ForEach(model.sourceSettings) { model in
                        SnapSourceSettingsView(model: model)
                            .padding(.leading)
                    }
                }
            }
        }
        .animation(.default, value: model.snapsToFeatures)
    }
}

private struct SnapSourceSettingsView: View {
    @State var model: SnapSourceSettingsModel
    
    var body: some View {
        Toggle(model.name, isOn: $model.isEnabled)
    }
}

private extension SnapSource {
    var name: String {
        switch self {
        case let featureLayer as FeatureLayer:
            return featureLayer.name
        case let overlay as GraphicsOverlay:
            return overlay.id
        default:
            return "Unknown"
        }
    }
}
