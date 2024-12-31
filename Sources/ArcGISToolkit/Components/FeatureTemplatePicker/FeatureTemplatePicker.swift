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

***REMOVED***/ A view that displays feature templates from a geo model
***REMOVED***/ and allows the user to choose a template.
public struct FeatureTemplatePicker: View {
***REMOVED******REMOVED***/ The model backing the feature template picker.
***REMOVED***@StateObject private var model: Model
***REMOVED******REMOVED***/ The selection
***REMOVED***@Binding private var selection: FeatureTemplateInfo?
***REMOVED***
***REMOVED******REMOVED***/ Creates a feature template picker.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoModel: The geo model from which feature templates will be displayed.
***REMOVED******REMOVED***/   - selection: The selected template.
***REMOVED******REMOVED***/   - includeNonCreatableFeatureTemplates: Include feature templates from tables where features cannot be created.
***REMOVED***public init(geoModel: GeoModel, selection: Binding<FeatureTemplateInfo?>, includeNonCreatableFeatureTemplates: Bool = false) {
***REMOVED******REMOVED***_model = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: Model(
***REMOVED******REMOVED******REMOVED******REMOVED***geoModel: geoModel,
***REMOVED******REMOVED******REMOVED******REMOVED***includeNonCreatableFeatureTemplates: includeNonCreatableFeatureTemplates
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.noFeatureTemplatesTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "mappin.slash.circle",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: Text(String.noFeatureTemplatesDetail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Fallback on earlier versions
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.noFeatureTemplatesDetail)
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
***REMOVED******REMOVED******REMOVED******REMOVED***.searchable(text: $model.searchText, prompt: String.searchTemplatesPrompt)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.showNoTemplatesFound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ContentUnavailableView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.noFeatureTemplatesFoundTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "magnifyingglass.circle",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: Text(String.noFeatureTemplatesFoundDetail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Fallback on earlier versions
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.noFeatureTemplatesFoundDetail)
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

private extension String {
***REMOVED***static var noFeatureTemplatesTitle: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "No Feature Templates",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A title for showing a view that tells the user there are no feature templates.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***static var noFeatureTemplatesDetail: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "There are no feature templates available.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** Details for showing a view that tells the user there are no feature templates
***REMOVED******REMOVED******REMOVED******REMOVED*** available.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***static var searchTemplatesPrompt: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "Search templates",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A prompt in the search templates text box that instructs the user that they
***REMOVED******REMOVED******REMOVED******REMOVED*** can type in the field to search for templates.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***static var noFeatureTemplatesFoundTitle: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "Nothing Found",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A title for showing a view that tells the user there were no feature templates
***REMOVED******REMOVED******REMOVED******REMOVED*** found that match their search criteria.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***static var noFeatureTemplatesFoundDetail: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "There were no feature templates found that match the search criteria.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** Details for showing a view that tells the user there were no feature templates
***REMOVED******REMOVED******REMOVED******REMOVED*** found that match their search criteria.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ View of a feature template.
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
***REMOVED******REMOVED***/ The model for the feature template picker.
***REMOVED***@MainActor
***REMOVED***final class Model: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The associated geo model.
***REMOVED******REMOVED***let geoModel: GeoModel
***REMOVED******REMOVED******REMOVED***/ Include feature templates from tables where features cannot be created.
***REMOVED******REMOVED***private let includeNonCreatableFeatureTemplates: Bool
***REMOVED******REMOVED******REMOVED***/ Search text for filtering the list of templates.
***REMOVED******REMOVED***var searchText: String = "" {
***REMOVED******REMOVED******REMOVED***didSet { templatesOrSearchTextDidChange() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ The complete unfiltered list of feature template sections.
***REMOVED******REMOVED***private var unfilteredFeatureTemplateSections = [FeatureTemplateSectionInfo]() {
***REMOVED******REMOVED******REMOVED***didSet { templatesOrSearchTextDidChange() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The sections.
***REMOVED******REMOVED***@Published fileprivate private(set) var featureTemplateSections = [FeatureTemplateSectionInfo]()
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether templates are being generated.
***REMOVED******REMOVED***@Published var isGeneratingFeatureTemplates = false
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating if content is unavailable.
***REMOVED******REMOVED***@Published var showContentUnavailable = false
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating if no templates were found with the given search text.
***REMOVED******REMOVED***@Published var showNoTemplatesFound = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a model for a given geo model.
***REMOVED******REMOVED***init(geoModel: GeoModel, includeNonCreatableFeatureTemplates: Bool) {
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED******REMOVED***self.includeNonCreatableFeatureTemplates = includeNonCreatableFeatureTemplates
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Generates the feature templates.
***REMOVED******REMOVED***func generateFeatureTemplates() async {
***REMOVED******REMOVED******REMOVED***isGeneratingFeatureTemplates = true
***REMOVED******REMOVED******REMOVED***defer { isGeneratingFeatureTemplates = false ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***unfilteredFeatureTemplateSections = await makeFeatureTemplateSections()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The feature template section information for the geo model.
***REMOVED******REMOVED***private func makeFeatureTemplateSections() async -> [FeatureTemplateSectionInfo] {
***REMOVED******REMOVED******REMOVED***try? await geoModel.load()
***REMOVED******REMOVED******REMOVED***var sections = [FeatureTemplateSectionInfo]()
***REMOVED******REMOVED******REMOVED***let layersAndTables = geoModel.arcGISFeatureLayersAndTables
***REMOVED******REMOVED******REMOVED***await layersAndTables.map(\.table).load()
***REMOVED******REMOVED******REMOVED***for (layer, table) in layersAndTables {
***REMOVED******REMOVED******REMOVED******REMOVED***guard includeNonCreatableFeatureTemplates || table.canAddFeature else { continue ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***var infos = [FeatureTemplateInfo]()
***REMOVED******REMOVED******REMOVED******REMOVED***for template in table.allTemplates {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let feature = table.makeFeature(template: template)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let symbol = layer.renderer?.symbol(for: feature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let scale: CGFloat
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale = 1
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale = UIScreen.main.scale
#endif
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
***REMOVED******REMOVED******REMOVED***return sections.filter { !$0.infos.isEmpty ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Re-filters based on the templates or the search text.
***REMOVED******REMOVED***private func templatesOrSearchTextDidChange() {
***REMOVED******REMOVED******REMOVED***featureTemplateSections = unfilteredFeatureTemplateSections.map {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.filtered(by: searchText)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.filter { !$0.infos.isEmpty ***REMOVED***
***REMOVED******REMOVED******REMOVED***showContentUnavailable = unfilteredFeatureTemplateSections.isEmpty
***REMOVED******REMOVED******REMOVED***showNoTemplatesFound = !showContentUnavailable && featureTemplateSections.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***

private extension Array<Layer> {
***REMOVED******REMOVED***/ A flattened list of the nested layers that this array of layers may contain.
***REMOVED***var flattened: [Layer] {
***REMOVED******REMOVED***flatMap { layer in
***REMOVED******REMOVED******REMOVED***guard let groupLayer = layer as? GroupLayer else { return [layer] ***REMOVED***
***REMOVED******REMOVED******REMOVED***return groupLayer.layers.flattened
***REMOVED***
***REMOVED***
***REMOVED***

private extension GeoModel {
***REMOVED******REMOVED***/ A list containing tuples of the feature layers and the associated
***REMOVED******REMOVED***/ ArcGIS feature tables in the geo model.
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
***REMOVED******REMOVED***/ All the feature layers in the geo model.
***REMOVED***var featureLayers: [FeatureLayer] {
***REMOVED******REMOVED***flattenedLayers
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? FeatureLayer ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A flattened list of the layers in the geo model.
***REMOVED***var flattenedLayers: [Layer] {
***REMOVED******REMOVED***layers.flattened
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ All the layers in the geo model.
***REMOVED***var layers: [Layer] {
***REMOVED******REMOVED***operationalLayers
***REMOVED******REMOVED***+ (basemap?.baseLayers ?? [])
***REMOVED******REMOVED***+ (basemap?.referenceLayers ?? [])
***REMOVED***
***REMOVED***

private extension ArcGISFeatureTable {
***REMOVED******REMOVED***/ A flattened list of the feature templates in the table.
***REMOVED***var allTemplates: [FeatureTemplate] {
***REMOVED******REMOVED***let typeTemplates = featureTypes
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.flatMap { $0.templates ***REMOVED***
***REMOVED******REMOVED***return featureTemplates + typeTemplates
***REMOVED***
***REMOVED***

***REMOVED***/ A value that represents a section in the feature template picker.
private struct FeatureTemplateSectionInfo: Identifiable {
***REMOVED***let table: ArcGISFeatureTable
***REMOVED***var infos: [FeatureTemplateInfo]
***REMOVED***let id: UUID = UUID()
***REMOVED***
***REMOVED***func filtered(by searchText: String) -> FeatureTemplateSectionInfo {
***REMOVED******REMOVED***guard !searchText.isEmpty else { return self ***REMOVED***
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.infos = copy.infos.filter { $0.template.name.localizedStandardContains(searchText) ***REMOVED***
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

***REMOVED***/ A value that represents a feature template in the picker.
public struct FeatureTemplateInfo: Identifiable, Equatable {
***REMOVED***public static func == (lhs: FeatureTemplateInfo, rhs: FeatureTemplateInfo) -> Bool {
***REMOVED******REMOVED***lhs.template === rhs.template
***REMOVED***
***REMOVED***
***REMOVED***public let layer: FeatureLayer
***REMOVED***public let table: ArcGISFeatureTable
***REMOVED***public let template: FeatureTemplate
***REMOVED***public let image: UIImage?
***REMOVED***
***REMOVED***public var id: ObjectIdentifier {
***REMOVED******REMOVED***ObjectIdentifier(template)
***REMOVED***
***REMOVED***
