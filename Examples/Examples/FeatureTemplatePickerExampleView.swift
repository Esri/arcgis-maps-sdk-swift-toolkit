***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ Allows a user to select a feature template and displays
***REMOVED***/ the name of the template that was selected.
struct FeatureTemplatePickerExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISTopographic)
***REMOVED******REMOVED***let featureTable = ServiceFeatureTable(url: URL(string: "https:***REMOVED***sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
***REMOVED******REMOVED***let featureLayer = FeatureLayer(featureTable: featureTable)
***REMOVED******REMOVED***map.addOperationalLayer(featureLayer)
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the feature template picker
***REMOVED******REMOVED***/ is presented.
***REMOVED***@State private var templatePickerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The selection of the feature template picker.
***REMOVED***@State private var selection: FeatureTemplateInfo?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $templatePickerIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureTemplatePicker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModel: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $selection,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***includeNonCreatableFeatureTemplates: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset selection when the picker appears.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle("Feature Templates")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Dismiss the template picker upon selection.
***REMOVED******REMOVED******REMOVED******REMOVED***if selection != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***templatePickerIsPresented = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***templatePickerIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Templates")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.safeAreaInset(edge: .top) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let selection {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let image = selection.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(selection.template.name) Template Selected")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
