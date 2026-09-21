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

/// A control for picking a geometry editing tool.
struct ToolPicker: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    var body: some View {
        @Bindable var geometryEditorModel = featureEditorModel.geometryEditorModel

        Menu {
            Picker(selection: $geometryEditorModel.selectedTool) {
                ForEach(geometryEditorModel.selectableTools, id: \.self) { tool in
                    Label(tool.label, systemImage: tool.systemImage)
                }
            } label: {
                Text.tool
            }
        } label: {
            Label {
                Text.tool
            } icon: {
                Image(systemName: geometryEditorModel.selectedTool.systemImage)
            }
        }
        .animation(.default, value: geometryEditorModel.selectedTool)
    }
}

// MARK: - Extensions

private extension Text {
    /// Localized text for the word "Tool".
    static var tool: Self {
        .init(
            "Tool",
            bundle: .toolkitModule,
            comment: "A label for a control to pick a geometry editor tool."
        )
    }
}

#Preview {
    @Previewable @State var featureEditorModel = FeatureEditorModel()
    
    ToolPicker()
        .environment(featureEditorModel)
        .task {
            featureEditorModel.geometryEditorModel.start(withType: Polygon.self)
            await featureEditorModel.geometryEditorModel.monitorStreams()
        }
}
