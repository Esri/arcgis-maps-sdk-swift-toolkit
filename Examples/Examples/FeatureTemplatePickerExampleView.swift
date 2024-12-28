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

struct FeatureTemplatePickerExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("9f3a674e998f461580006e626611f9ad")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var isShowingTemplates = false
***REMOVED***
***REMOVED***@State private var selection: FeatureTemplateInfo?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isShowingTemplates) {
***REMOVED******REMOVED******REMOVED******REMOVED***FeatureTemplatePicker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModel: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $selection,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***includeNonCreatableFeatureTemplates: true
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingTemplates = true
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Templates")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
