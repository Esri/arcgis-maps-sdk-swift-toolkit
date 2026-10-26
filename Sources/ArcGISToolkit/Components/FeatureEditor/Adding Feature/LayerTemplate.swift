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
    /// The feature table associated with this template.
    let featureTable: ArcGISFeatureTable
    /// The shared template used to create a feature.
    let sharedTemplate: SharedTemplate
}

extension LayerTemplate {
    /// The identifier of the feature layer associated with this template.
    var layerID: Int { featureTable.serviceLayerID }
    
    /// The name of this template.
    var name: String { sharedTemplate.name }
    
    /// Creates a set of features based on the specified geometry.
    /// - Parameter geometry: The geometry from which features are created.
    func makeFeatures(geometry: Geometry?) async throws -> SharedTemplateFeatureCreationSet {
        return try await sharedTemplate.source
            .makeFeatures(sharedTemplate: sharedTemplate, geometry: geometry)
    }
    
    /// Creates a swatch image with the template’s thumbnail or symbology.
    @MainActor func makeSwatch() async throws -> UIImage {
        return try await sharedTemplate.makeSwatch(layerID: layerID)
    }
    
    /// The kinds of construction tools supported by this template.
    var constructionToolKinds: [GeometryConstructionTool.Kind] {
        get async throws {
            try await sharedTemplate.load()
            return GeometryConstructionTool.Kind.supportedCases
                .filter { sharedTemplate.isTool($0, applicableForLayerWithID: layerID) }
        }
    }
    
    /// The default construction tool for this template.
    var defaultConstructionTool: GeometryConstructionTool? {
        sharedTemplate.defaultConstructionTool(forLayerWithID: layerID)
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

private extension GeometryConstructionTool.Kind {
    /// The kinds of geometry construction tools supported by the feature
    /// editor.
    static var supportedCases: [Self] {
        [
            .circle,
            .ellipse,
            .freehand,
            .line,
            .multipoint,
            .point,
            .polygon,
            .rectangle
        ]
    }
}
