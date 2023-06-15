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

import FormsPlugin

public struct Forms: View {
***REMOVED***@State private var rawJSON: String?
***REMOVED***
***REMOVED***@State private var mapInfo: MapInfo?
***REMOVED***
***REMOVED***private var attributes: [String : Any]?
***REMOVED***
***REMOVED***private let map: Map
***REMOVED***
***REMOVED******REMOVED***/ - Parameter feature: The feature to be edited.
***REMOVED***public init(map: Map, feature: ArcGISFeature) {
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.attributes = feature.attributes
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***Text(mapInfo?.operationalLayers.first?.featureFormDefinition.title ?? "Form Title Unavailable")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.largeTitle)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***ForEach(mapInfo?.operationalLayers.first?.featureFormDefinition.formElements ?? [], id: \.element?.label) { container in
***REMOVED******REMOVED******REMOVED******REMOVED***if let element = container.element as? FieldFeatureFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch element.inputType.input {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case is TextBoxFeatureFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SingleLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: element.label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: attributes?[element.fieldName] as? String ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: element.hint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case is TextAreaFeatureFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MultiLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: attributes?[element.fieldName] as? String ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***input: element.inputType.input as! TextAreaFeatureFormInput
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Unknown Input Type",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "An error when a form element is of an unknown type."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
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
