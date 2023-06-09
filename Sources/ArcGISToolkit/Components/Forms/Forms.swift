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
***REMOVED******REMOVED******REMOVED***Text(mapInfo?.operationalLayers.first?.formInfo.title ?? "Form Title Unavailable")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.largeTitle)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***ForEach(mapInfo?.operationalLayers.first?.formInfo.formElements ?? [], id: \.fieldName) { element in
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
***REMOVED******REMOVED******REMOVED***mapInfo = try? decoder.decode(MapInfo.self, from: self.rawJSON!.data(using: .utf8)!)
***REMOVED***
***REMOVED***
***REMOVED***

struct MapInfo: Decodable {
***REMOVED***var operationalLayers: [OperationalLayer]
***REMOVED***

struct OperationalLayer: Decodable {
***REMOVED***var formInfo: FormInfo
***REMOVED***

struct FormInfo: Decodable {
***REMOVED***var title: String
***REMOVED***var formElements: [FormElement]
***REMOVED***

struct FormElement: Decodable {
***REMOVED***var description: String
***REMOVED***var fieldName: String
***REMOVED***var hint: String
***REMOVED***var inputType: InputType
***REMOVED***var label: String
***REMOVED***var type: String
***REMOVED***

struct InputType: Decodable {
***REMOVED***var type: String
***REMOVED***var minLength: Int
***REMOVED***var maxLength: Int
***REMOVED***
