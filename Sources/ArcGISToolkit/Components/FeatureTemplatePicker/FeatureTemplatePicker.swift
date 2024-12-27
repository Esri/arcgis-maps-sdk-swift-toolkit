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
***REMOVED***

public struct FeatureTemplatePicker: View {
***REMOVED******REMOVED***/ The model backing the feature template picker.
***REMOVED***@StateObject var model: Model
***REMOVED***@Binding var selection: FeatureTemplateInfo?
***REMOVED***
***REMOVED***init(geoModel: GeoModel, selection: Binding<FeatureTemplateInfo?>) {
***REMOVED******REMOVED***_model = StateObject(wrappedValue: Model(geoModel: geoModel))
***REMOVED******REMOVED***_selection = selection
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if model.isGeneratingFeatureTemplates {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else if model.showContentUnavailable {
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ContentUnavailableView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"No Feature Templates",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "list.bullet",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: Text("No feature templates available for this map.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Fallback on earlier versions
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No feature templates available for this map.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(model.featureTemplateSections) { section in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section(section.table.displayName) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(section.infos) { info in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureTemplateView(info: info, selection: _selection)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***await model.generateFeatureTemplates()
***REMOVED***
***REMOVED***
***REMOVED***

private struct FeatureTemplateView: View {
***REMOVED***let info: FeatureTemplateInfo
***REMOVED***@Binding var selection: FeatureTemplateInfo?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(info.template.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = info.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if info == selection {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***selection = info
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureTemplatePicker {
***REMOVED******REMOVED***/ The model for the legend.
***REMOVED***@MainActor
***REMOVED***final class Model: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The associated geo model.
***REMOVED******REMOVED***let geoModel: GeoModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The templates.
***REMOVED******REMOVED***@Published fileprivate var featureTemplateSections = [FeatureTemplateSectionInfo]()
***REMOVED******REMOVED***@Published var isGeneratingFeatureTemplates = false
***REMOVED******REMOVED***@Published var showContentUnavailable = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a model for a given geo model.
***REMOVED******REMOVED***init(geoModel: GeoModel) {
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Generates the feature templates.
***REMOVED******REMOVED***func generateFeatureTemplates() async {
***REMOVED******REMOVED******REMOVED***isGeneratingFeatureTemplates = true
***REMOVED******REMOVED******REMOVED***defer { isGeneratingFeatureTemplates = false ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***featureTemplateSections = await geoModel.featureTemplateSections
***REMOVED***
***REMOVED***
***REMOVED***

extension GeoModel {
***REMOVED***var arcGISFeatureLayersAndTables: [(layer: FeatureLayer, table: ArcGISFeatureTable)] {
***REMOVED******REMOVED***featureLayers
***REMOVED******REMOVED******REMOVED***.map { (layer: $0, table: $0.featureTable) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.compactMap { tuple in
***REMOVED******REMOVED******REMOVED******REMOVED***if let table = tuple.table as? ArcGISFeatureTable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return (layer: tuple.layer, table: table)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension GeoModel {
***REMOVED***var featureTemplateSections: [FeatureTemplateSectionInfo] {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***var sections = [FeatureTemplateSectionInfo]()
***REMOVED******REMOVED******REMOVED***for (layer, table) in self.arcGISFeatureLayersAndTables {
***REMOVED******REMOVED******REMOVED******REMOVED***var infos = [FeatureTemplateInfo]()
***REMOVED******REMOVED******REMOVED******REMOVED***for template in table.allTemplates {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let feature = table.makeFeature(template: template)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let symbol = layer.renderer?.symbol(for: feature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let image = try? await symbol?.makeSwatch(scale: UIScreen.main.scale)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***infos.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureTemplateInfo(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***layer: layer,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***table: table,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***template: template,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image: image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sections.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.init(table: table, infos: infos)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return sections
***REMOVED***
***REMOVED***
***REMOVED***

extension ArcGISFeatureTable {
***REMOVED***var allTemplates: [FeatureTemplate] {
***REMOVED******REMOVED***let typeTemplates = featureTypes
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.flatMap { $0.templates ***REMOVED***
***REMOVED******REMOVED***return featureTemplates + typeTemplates
***REMOVED***
***REMOVED***

private struct FeatureTemplateSectionInfo: Identifiable {
***REMOVED***let table: ArcGISFeatureTable
***REMOVED***let infos: [FeatureTemplateInfo]
***REMOVED***
***REMOVED***var id: ObjectIdentifier {
***REMOVED******REMOVED***ObjectIdentifier(table)
***REMOVED***
***REMOVED***

struct FeatureTemplateInfo: Identifiable, Equatable {
***REMOVED***static func == (lhs: FeatureTemplateInfo, rhs: FeatureTemplateInfo) -> Bool {
***REMOVED******REMOVED***lhs.template === rhs.template
***REMOVED***
***REMOVED***
***REMOVED***let layer: FeatureLayer
***REMOVED***let table: ArcGISFeatureTable
***REMOVED***let template: FeatureTemplate
***REMOVED***let image: UIImage?
***REMOVED***
***REMOVED***var id: ObjectIdentifier {
***REMOVED******REMOVED***ObjectIdentifier(template)
***REMOVED***
***REMOVED***
