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
import Foundation
import Observation
import SwiftUI

/// A shared template associated with a feature layer.
struct LayerTemplate: Identifiable {
    let id = UUID()
    /// The identifier of the feature layer associated with this template.
    let layerID: Int
    /// The shared template used to create a feature.
    let sharedTemplate: SharedTemplate
}

extension LayerTemplate {
    /// The name of this template.
    var name: String { sharedTemplate.name }
    
    /// Creates a swatch image with the template’s thumbnail or symbology.
    func makeSwatch() async throws -> UIImage {
        return try await sharedTemplate.makeSwatch(layerID: layerID)
    }
}

extension LayerTemplate: Equatable {
    static func == (lhs: LayerTemplate, rhs: LayerTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}

extension LayerTemplate: Hashable {
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
