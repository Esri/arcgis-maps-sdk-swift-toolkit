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

public struct Forms: View {
    @State private var rawJSON: String?
    
    @State private var mapInfo: MapInfo?
    
    private let map: Map
    
    public init(map: Map) {
        self.map = map
    }
    
    struct TextBoxEntry: View {
        @State private var text: String = ""
        
        var title: String
        
        public var body: some View {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    struct TextAreaEntry: View {
        @State private var text: String = ""
        
        @FocusState var isActive: Bool
        
        public var body: some View {
            TextEditor(text: $text)
                .padding(1.5)
                .border(.gray.opacity(0.2))
                .cornerRadius(5)
                .focused($isActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isActive {
                            Spacer()
                            Button("Done") {
                                isActive.toggle()
                            }
                        }
                    }
                }
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(mapInfo?.operationalLayers.first?.formInfo.title ?? "Form Title Unavailable")
                .font(.largeTitle)
            Divider()
            ForEach(mapInfo?.operationalLayers.first?.formInfo.formElements ?? [], id: \.fieldName) { element in
                Text(element.label)
                    .font(.headline)
                Text(element.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                switch element.inputType.type {
                case "text-box":
                    TextBoxEntry(title: element.hint)
                case "text-area":
                    TextAreaEntry()
                default:
                    Text("Unknown Input Type", bundle: .module, comment: "An error when a form element has an unknown type.")
                }
            }
        }
        .task {
            try? await map.load()
            rawJSON = map.toJSON()
            
            let decoder = JSONDecoder()
            mapInfo = try? decoder.decode(MapInfo.self, from: self.rawJSON!.data(using: .utf8)!)
        }
    }
}

struct MapInfo: Decodable {
    var operationalLayers: [OperationalLayer]
}

struct OperationalLayer: Decodable {
    var formInfo: FormInfo
}

struct FormInfo: Decodable {
    var title: String
    var formElements: [FormElement]
}

struct FormElement: Decodable {
    var description: String
    var fieldName: String
    var hint: String
    var inputType: InputType
    var label: String
    var type: String
}

struct InputType: Decodable {
    var type: String
    var minLength: Int
    var maxLength: Int
}
