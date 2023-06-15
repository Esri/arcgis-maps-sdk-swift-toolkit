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
import SwiftUI

import FormsPlugin

public struct Forms: View {
    @State private var rawJSON: String?
    
    @State private var mapInfo: MapInfo?
    
    private var attributes: [String : Any]?
    
    private let map: Map
    
    /// - Parameter feature: The feature to be edited.
    public init(map: Map, feature: ArcGISFeature) {
        self.map = map
        self.attributes = feature.attributes
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(mapInfo?.operationalLayers.first?.featureFormDefinition.title ?? "Form Title Unavailable")
                .font(.largeTitle)
            Divider()
            ForEach(mapInfo?.operationalLayers.first?.featureFormDefinition.formElements ?? [], id: \.element?.label) { container in
                if let element = container.element as? FieldFeatureFormElement {
                    Text(element.label)
                        .font(.headline)
                    Text(element.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    switch element.inputType.input {
                    case is TextBoxFeatureFormInput:
                        SingleLineTextEntry(
                            title: element.label,
                            value: attributes?[element.fieldName] as? String ?? "",
                            prompt: element.hint
                        )
                    case is TextAreaFeatureFormInput:
                        MultiLineTextEntry(
                            value: attributes?[element.fieldName] as? String ?? "",
                            input: element.inputType.input as! TextAreaFeatureFormInput
                        )
                    default:
                        Text(
                            "Unknown Input Type",
                            bundle: .toolkitModule,
                            comment: "An error when a form element is of an unknown type."
                        )
                    }
                }
            }
        }
        .task {
            try? await map.load()
            rawJSON = map.toJSON()
            
            let decoder = JSONDecoder()
            do {
                mapInfo = try decoder.decode(MapInfo.self, from: self.rawJSON!.data(using: .utf8)!)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
