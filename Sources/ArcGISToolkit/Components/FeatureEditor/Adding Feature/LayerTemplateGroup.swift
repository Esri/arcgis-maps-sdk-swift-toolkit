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

import Foundation
import Observation

/// A group of layer templates displayed in the feature template picker.
@MainActor
@Observable
final class LayerTemplateGroup: Identifiable {
    let id: UUID
    /// The name of this group.
    let name: String
    /// The layer templates contained in this group.
    let layerTemplates: [LayerTemplate]
    /// A Boolean value that indicates whether the group is expanded.
    var isExpanded = true
    
    /// Creates a layer template with the given parameters.
    /// - Parameters:
    ///   - id: The stable identity of the group.
    ///   - name: The name of the group.
    ///   - layerTemplates: The layer templates contained in the group.
    nonisolated init(id: UUID = UUID(), name: String, layerTemplates: [LayerTemplate]) {
        self.id = id
        self.name = name
        self.layerTemplates = layerTemplates
    }
}
