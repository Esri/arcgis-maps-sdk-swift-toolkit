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

/// A view that displays a list of layer templates.
struct FeatureEditorTemplatePicker: View {
    /// The model that manages the feature-adding workflow.
    @Environment(FeatureAddingModel.self) private var model
    
    /// The text used to filter the available template groups.
    @State private var searchText = ""
    
    /// The template groups whose names or template names match the search text.
    var filteredGroups: [LayerTemplateGroup] {
        guard !searchText.isEmpty else { return model.groups }
        return model.groups.reduce(into: []) { partialResult, group in
            if group.name.localizedCaseInsensitiveContains(searchText) {
                partialResult.append(group)
            } else {
                let filteredLayers = group.layerTemplates
                    .filter { $0.sharedTemplate.name.localizedCaseInsensitiveContains(searchText) }
                if !filteredLayers.isEmpty {
                    let new = LayerTemplateGroup(
                        id: group.id,
                        name: group.name,
                        layerTemplates: filteredLayers
                    )
                    partialResult.append(new)
                }
            }
        }
    }
    
    var body: some View {
        @Bindable var model = model
        NavigationStack(path: $model.navigationPath) {
            Group {
                if let featureForm = model.featureForm {
                    FeatureFormView(root: featureForm, isPresented: $model.isPresented)
                } else {
                    Form {
                        ForEach(filteredGroups) { group in
                            FeatureEditorTemplatePickerGroup(group: group, searchText: searchText)
                        }
                    }
                    .navigationTitle(
                        LocalizedStringResource(
                            "Templates",
                            bundle: .toolkit,
                            comment: "The title of the template picker view."
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: LayerTemplate.self) { layerTemplate in
                        TemplateGeometryConstructionView(layerTemplate: layerTemplate) { featureForm in
                            model.featureForm = featureForm
                        }
                    }
                    .searchable(
                        text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always)
                    )
                }
            }
        }
        .toolbar {
            if model.featureForm == nil {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton(kind: .close) {
                        withAnimation {
                            model.stop()
                        }
                    }
                }
            }
        }
    }
}
