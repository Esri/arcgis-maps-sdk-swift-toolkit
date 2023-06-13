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

public final class MapInfo: Decodable {
    var operationalLayers: [OperationalLayer]
}

public final class OperationalLayer: Decodable {
    var featureFormDefinition: FeatureFormDefinition
    
    enum CodingKeys: String, CodingKey {
        case formInfo
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        featureFormDefinition = try values.decode(FeatureFormDefinition.self, forKey: CodingKeys.formInfo)
    }
}

public final class FeatureFormDefinition: Decodable {
    /// A string that describes the element in detail.
    // public var description: String
    
    /// An array of FeatureFormExpressionInfo objects that represent the Arcade expressions used in the form.
    public var expressionInfos: [FeatureFormExpressionInfo]
    
    /// An array of FormElement objects that represent an ordered list of form elements.
    public var formElements: [FeatureFormElementContainer]
    
    /// Determines whether a previously visible formFieldElement value is retained or
    /// cleared when a visibilityExpression applied on the formFieldElement or its parent
    /// formGroupElement evaluates to `false`. Default is `false`.
    // public var preserveFieldValuesWhenHidden: Bool
    
    /// The form title.
    public var title: String
}

/// Arcade expression used in the form.
public final class FeatureFormExpressionInfo: Decodable {
    /// The Arcade expression.
    public var expression: String
    
    /// Unique identifier for the expression.
    public var name: String
    
    /// Return type of the Arcade expression. This can be determined by the authoring
    /// client by executing the expression using a sample feature(s), although it can
    /// be corrected by the user.
    public var returnType: String
    
    /// Title of the expression.
    public var title: String
    
    init(expression: String, name: String, returnType: String, title: String) {
        self.expression = expression
        self.name = name
        self.returnType = returnType
        self.title = title
    }
}

/// A feature form element container.
public final class FeatureFormElementContainer: Decodable {
    var element: FeatureFormElement?
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        if type == "field" {
            element = try FieldFeatureFormElement(from: decoder)
        }
    }
}

/// An interface containing properties common to feature form elements.
public protocol FeatureFormElement: Decodable {
    /// A string that describes the element in detail.
    var description: String { get set }
    
    /// A string indicating what the element represents. If not supplied, the label is derived
    /// from the alias property in the referenced field in the service.
    var label: String { get set }
    
    /// A reference to an Arcade expression that returns a boolean value. When this expression evaluates to `true`,
    /// the element is displayed. When the expression evaluates to `false` the element is not displayed. If no expression
    /// is provided, the default behavior is that the element is displayed. Care must be taken when defining a
    /// visibility expression for a non-nullable field i.e. to make sure that such fields either have default values
    /// or are made visible to users so that they can provide a value before submitting the form.
    // var visibilityExpressionName: String { get set }
}

public final class GroupFeatureFormElement: FeatureFormElement {
    public var description: String
    
    public var label: String
    
    public var visibilityExpressionName: String
}

public final class FieldFeatureFormElement: FeatureFormElement {
    public var description: String
    
    public var fieldName: String
    
    public var hint: String
    
    public var inputType: InputType
    
    public var label: String
    
    public var type: String
}

public final class InputType: Decodable {
    var type: String
    var minLength: Int
    var maxLength: Int
}
