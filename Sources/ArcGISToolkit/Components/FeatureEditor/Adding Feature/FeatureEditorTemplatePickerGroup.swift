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

/// A disclosure group that displays the templates for a layer.
struct FeatureEditorTemplatePickerGroup: View {
    /// The layer template group displayed by the disclosure group.
    let group: LayerTemplateGroup
    /// The text to emphasize within each layer template's name.
    let searchText: String
    
    /// A Boolean value that indicates whether the user is searching.
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        @Bindable var group = group
        DisclosureGroup(isExpanded: !isSearching ? $group.isExpanded : .constant(true)) {
            ForEach(group.layerTemplates) { layerTemplate in
                NavigationLink(value: layerTemplate) {
                    FeatureEditorTemplatePickerGroupRow(
                        layerTemplate: layerTemplate,
                        searchText: searchText
                    )
                }
            }
        } label: {
            Text(group.name.bolding(group.name))
        }
    }
}
