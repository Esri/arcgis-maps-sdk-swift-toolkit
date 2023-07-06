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
import FormsPlugin
***REMOVED***

***REMOVED***/ Forms allow users to edit information about GIS features.
***REMOVED***/ - Since: 200.2
public struct FormView: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***@State private var formDefinition: FeatureFormDefinition?
***REMOVED***
***REMOVED******REMOVED***/ Info obtained from the map's JSON which contains the underlying form definition.
***REMOVED***@State private var mapInfo: MapInfo?
***REMOVED***
***REMOVED******REMOVED***/ The feature being edited in the form.
***REMOVED***private let feature: ArcGISFeature
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FormView` with the given feature.
***REMOVED******REMOVED***/ - Parameter feature: The feature to be edited.
***REMOVED***public init(feature: ArcGISFeature) {
***REMOVED******REMOVED***self.feature = feature
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***FormHeader(title: formDefinition?.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(formDefinition?.formElements ?? [], id: \.element?.label) { container in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let element = container.element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***let decoder = JSONDecoder()
***REMOVED******REMOVED******REMOVED***if let layer = feature.table?.layer as? FeatureLayer,
***REMOVED******REMOVED******REMOVED***   let formInfoDictionary = layer._unsupportedJSON["formInfo"],
***REMOVED******REMOVED******REMOVED***   let jsonData = try? JSONSerialization.data(withJSONObject: formInfoDictionary),
***REMOVED******REMOVED******REMOVED***   let formDefinition = try? decoder.decode(FeatureFormDefinition.self, from: jsonData) {
***REMOVED******REMOVED******REMOVED******REMOVED***self.formDefinition = formDefinition
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Error processing form definition")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FormView {
***REMOVED******REMOVED***/ Makes UI for a form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeElement(_ element: FeatureFormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFeatureFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as GroupFeatureFormElement:
***REMOVED******REMOVED******REMOVED***makeGroupElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeFieldElement(_ element: FieldFeatureFormElement) -> some View {
***REMOVED******REMOVED***switch element.inputType.input {
***REMOVED******REMOVED***case let `input` as TextBoxFeatureFormInput:
***REMOVED******REMOVED******REMOVED***SingleLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***text: feature.attributes[element.fieldName] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED***input: `input`
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case let `input` as TextAreaFeatureFormInput:
***REMOVED******REMOVED******REMOVED***MultiLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***text: feature.attributes[element.fieldName] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED***input: `input`
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a group form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeGroupElement(_ element: GroupFeatureFormElement) -> some View {
***REMOVED******REMOVED***DisclosureGroup(element.label) {
***REMOVED******REMOVED******REMOVED***ForEach(element.formElements, id: \.element?.label) { container in
***REMOVED******REMOVED******REMOVED******REMOVED***if let element = container.element as? FieldFeatureFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
