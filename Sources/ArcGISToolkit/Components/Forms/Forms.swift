***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

public struct Forms: View {
***REMOVED***@State private var rawJSON: String?
***REMOVED***
***REMOVED***@State private var mapInfo: MapInfo?
***REMOVED***
***REMOVED***private let map: Map
***REMOVED***
***REMOVED***public init(map: Map) {
***REMOVED******REMOVED***self.map = map
***REMOVED***
***REMOVED***
***REMOVED***struct TextBoxEntry: View {
***REMOVED******REMOVED***@State private var text: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED***var title: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***public var body: some View {
***REMOVED******REMOVED******REMOVED***TextField(title, text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.textFieldStyle(.roundedBorder)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct TextAreaEntry: View {
***REMOVED******REMOVED***@State private var text: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED***@FocusState var isActive: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED***public var body: some View {
***REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(1.5)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(.gray.opacity(0.2))
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(5)
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isActive)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .keyboard) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isActive {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isActive.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***Text(mapInfo?.operationalLayers.first?.featureFormDefinition.title ?? "Form Title Unavailable")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.largeTitle)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***ForEach(mapInfo?.operationalLayers.first?.featureFormDefinition.formElements ?? [], id: \.fieldName) { element in
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***switch element.inputType.type {
***REMOVED******REMOVED******REMOVED******REMOVED***case "text-box":
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextBoxEntry(title: element.hint)
***REMOVED******REMOVED******REMOVED******REMOVED***case "text-area":
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextAreaEntry()
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Unknown Input Type", bundle: .module, comment: "An error when a form element has an unknown type.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await map.load()
***REMOVED******REMOVED******REMOVED***rawJSON = map.toJSON()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let decoder = JSONDecoder()
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***mapInfo = try decoder.decode(MapInfo.self, from: self.rawJSON!.data(using: .utf8)!)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

public final class MapInfo: Decodable {
***REMOVED***var operationalLayers: [OperationalLayer]
***REMOVED***

public final class OperationalLayer: Decodable {
***REMOVED***var featureFormDefinition: FeatureFormDefinition
***REMOVED***
***REMOVED***enum CodingKeys: String, CodingKey {
***REMOVED******REMOVED***case formInfo
***REMOVED***
***REMOVED***
***REMOVED***public required init(from decoder: Decoder) throws {
***REMOVED******REMOVED***let values = try decoder.container(keyedBy: CodingKeys.self)
***REMOVED******REMOVED***featureFormDefinition = try values.decode(FeatureFormDefinition.self, forKey: CodingKeys.formInfo)
***REMOVED***
***REMOVED***

public final class FeatureFormDefinition: Decodable {
***REMOVED******REMOVED***/ A string that describes the element in detail.
***REMOVED******REMOVED*** public var description: String
***REMOVED***
***REMOVED******REMOVED***/ An array of FeatureFormExpressionInfo objects that represent the Arcade expressions used in the form.
***REMOVED***public var expressionInfos: [FeatureFormExpressionInfo]
***REMOVED***
***REMOVED******REMOVED***/ An array of FormElement objects that represent an ordered list of form elements.
***REMOVED***public var formElements: [FeatureFormElement]
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a previously visible formFieldElement value is retained or
***REMOVED******REMOVED***/ cleared when a visibilityExpression applied on the formFieldElement or its parent
***REMOVED******REMOVED***/ formGroupElement evaluates to `false`. Default is `false`.
***REMOVED******REMOVED*** public var preserveFieldValuesWhenHidden: Bool
***REMOVED***
***REMOVED******REMOVED***/ The form title.
***REMOVED***public var title: String
***REMOVED***

***REMOVED***/ Arcade expression used in the form.
public final class FeatureFormExpressionInfo: Decodable {
***REMOVED******REMOVED***/ The Arcade expression.
***REMOVED***public var expression: String
***REMOVED***
***REMOVED******REMOVED***/ Unique identifier for the expression.
***REMOVED***public var name: String
***REMOVED***
***REMOVED******REMOVED***/ Return type of the Arcade expression. This can be determined by the authoring
***REMOVED******REMOVED***/ client by executing the expression using a sample feature(s), although it can
***REMOVED******REMOVED***/ be corrected by the user.
***REMOVED***public var returnType: String
***REMOVED***
***REMOVED******REMOVED***/ Title of the expression.
***REMOVED***public var title: String
***REMOVED***
***REMOVED***init(expression: String, name: String, returnType: String, title: String) {
***REMOVED******REMOVED***self.expression = expression
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.returnType = returnType
***REMOVED******REMOVED***self.title = title
***REMOVED***
***REMOVED***

***REMOVED***/ An interface containing properties common to feature form elements.
public final class FeatureFormElement: Decodable {
***REMOVED******REMOVED***/ A string that describes the element in detail.
***REMOVED***var description: String
***REMOVED***
***REMOVED***var fieldName: String
***REMOVED***
***REMOVED***var hint: String
***REMOVED***
***REMOVED***var inputType: InputType
***REMOVED***
***REMOVED******REMOVED***/ A string indicating what the element represents. If not supplied, the label is derived
***REMOVED******REMOVED***/ from the alias property in the referenced field in the service.
***REMOVED***var label: String
***REMOVED***
***REMOVED******REMOVED***/ A reference to an Arcade expression that returns a boolean value. When this expression evaluates to `true`,
***REMOVED******REMOVED***/ the element is displayed. When the expression evaluates to `false` the element is not displayed. If no expression
***REMOVED******REMOVED***/ is provided, the default behavior is that the element is displayed. Care must be taken when defining a
***REMOVED******REMOVED***/ visibility expression for a non-nullable field i.e. to make sure that such fields either have default values
***REMOVED******REMOVED***/ or are made visible to users so that they can provide a value before submitting the form.
***REMOVED******REMOVED*** var visibilityExpressionName: String { get set ***REMOVED***
***REMOVED***
***REMOVED***var type: String
***REMOVED***

public final class InputType: Decodable {
***REMOVED***var type: String
***REMOVED***var minLength: Int
***REMOVED***var maxLength: Int
***REMOVED***
