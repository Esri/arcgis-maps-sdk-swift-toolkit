// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import FormsPlugin
import SwiftUI

/// Forms allow users to edit information about GIS features.
/// - Since: 200.2
public struct Form: View {
    /// Info obtained from the map's JSON which contains the underlying form definition.
    @State private var mapInfo: MapInfo?
    
    /// The attributes of the provided feature.
    private let attributes: [String : Any]?
    
    /// The map containing the underlying form definition.
    private let map: Map
    
    /// Creates a `Form` with the given map and feature.
    /// - Parameter map: The map containing the underlying form definition.
    /// - Parameter feature: The feature to be edited.
    public init(map: Map, feature: ArcGISFeature) {
        self.map = map
        self.attributes = feature.attributes
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                FormHeader(title: formDefinition?.title)
                Divider()
                ForEach(formDefinition?.formElements ?? [], id: \.element?.label) { container in
                    if let element = container.element as? FieldFeatureFormElement {
                        switch element.inputType.input {
                        case let `input` as TextBoxFeatureFormInput:
                            SingleLineTextEntry(
                                element: element,
                                text: attributes?[element.fieldName] as? String,
                                input: `input`
                            )
                        case let `input` as TextAreaFeatureFormInput:
                            MultiLineTextEntry(
                                element: element,
                                text: attributes?[element.fieldName] as? String,
                                input: `input`
                            )
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .task {
            let rawJSON = map.toJSON()
            let decoder = JSONDecoder()
            mapInfo = try? decoder.decode(MapInfo.self, from: rawJSON.data(using: .utf8)!)
        }
    }
}

extension Form {
    /// A shortcut to `mapInfo`s first operational layer form definition.
    var formDefinition: FeatureFormDefinition? {
        mapInfo?.operationalLayers.first?.featureFormDefinition
    }
}
