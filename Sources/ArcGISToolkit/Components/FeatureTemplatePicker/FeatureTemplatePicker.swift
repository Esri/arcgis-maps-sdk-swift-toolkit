// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// A view that displays feature temmplates from a geo model.
public struct FeatureTemplatePicker: View {
    /// The model backing the feature template picker.
    @StateObject private var model: Model
    /// The selection
    @Binding private var selection: FeatureTemplateInfo?
    
    /// Creates a feature template picker.
    /// - Parameters:
    ///   - geoModel: The geo model from which feature templates will be displayed.
    ///   - selection: The selected template.
    ///   - includeNonCreatableFeatureTemplates: Include feature templates from tables where features cannot be created.
    public init(geoModel: GeoModel, selection: Binding<FeatureTemplateInfo?>, includeNonCreatableFeatureTemplates: Bool = false) {
        _model = StateObject(
            wrappedValue: Model(
                geoModel: geoModel,
                includeNonCreatableFeatureTemplates: includeNonCreatableFeatureTemplates
            )
        )
        _selection = selection
    }
    
    public var body: some View {
        Group {
            if model.isGeneratingFeatureTemplates {
                ProgressView()
            } else if model.showContentUnavailable {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(
                        String.noFeatureTemplatesTitle,
                        systemImage: "mappin.slash.circle",
                        description: Text(String.noFeatureTemplatesDetail)
                    )
                } else {
                    // Fallback on earlier versions
                    Text(String.noFeatureTemplatesDetail)
                }
            } else {
                List {
                    ForEach(model.featureTemplateSections) { section in
                        Section(section.table.displayName) {
                            ForEach(section.infos) { info in
                                FeatureTemplateView(info: info, selection: _selection)
                            }
                        }
                    }
                }
                .searchable(text: $model.searchText, prompt: String.searchTemplatesPrompt)
                .overlay {
                    if model.showNoTemplatesFound {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView(
                                String.noFeatureTemplatesFoundTitle,
                                systemImage: "magnifyingglass.circle",
                                description: Text(String.noFeatureTemplatesFoundDetail)
                            )
                        } else {
                            // Fallback on earlier versions
                            Text(String.noFeatureTemplatesFoundDetail)
                        }
                    }
                }
            }
        }
        .task {
            await model.generateFeatureTemplates()
        }
    }
}

private extension String {
    static var noFeatureTemplatesTitle: String {
        String(
            localized: "No Feature Templates",
            bundle: .toolkitModule,
            comment: """
                 A title for showing a view that tells the user there are no feature templates.
                 """
        )
    }
    static var noFeatureTemplatesDetail: String {
        String(
            localized: "There are no feature templates available for this map.",
            bundle: .toolkitModule,
            comment: """
                 Details for showing a view that tells the user there are no feature templates
                 available in this map.
                 """
        )
    }
    static var searchTemplatesPrompt: String {
        String(
            localized: "Search templates",
            bundle: .toolkitModule,
            comment: """
                 A prompt in the search templates text box that instructs the user that they
                 can type in the field to search for templates.
                 """
        )
    }
    static var noFeatureTemplatesFoundTitle: String {
        String(
            localized: "Nothing Found",
            bundle: .toolkitModule,
            comment: """
                 A title for showing a view that tells the user there were no feature templates
                 found that match their search criteria.
                 """
        )
    }
    static var noFeatureTemplatesFoundDetail: String {
        String(
            localized: "There were no feature templates found that match the search criteria.",
            bundle: .toolkitModule,
            comment: """
                 Details for showing a view that tells the user there were no feature templates
                 found that match their search criteria.
                 """
        )
    }
}

/// View of a feature teamplate.
private struct FeatureTemplateView: View {
    let info: FeatureTemplateInfo
    @Binding var selection: FeatureTemplateInfo?
    
    var body: some View {
        HStack {
            Label {
                Text(info.template.name)
                    .lineLimit(1)
            } icon: {
                if let image = info.image {
                    Image(uiImage: image)
                } else {
                    Image(systemName: "minus")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if info == selection {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selection = info
        }
    }
}

extension FeatureTemplatePicker {
    /// The model for the feature template picker.
    @MainActor
    final class Model: ObservableObject {
        /// The associated geo model.
        let geoModel: GeoModel
        /// Include feature templates from tables where features cannot be created.
        private let includeNonCreatableFeatureTemplates: Bool
        /// Search text for filtering the list of templates.
        var searchText: String = "" {
            didSet { templatesOrSearchTextDidChange() }
        }
        /// The complete unfiltered list of feature template sections.
        private var unfilteredFeatureTemplateSections = [FeatureTemplateSectionInfo]() {
            didSet { templatesOrSearchTextDidChange() }
        }
        
        /// The sections.
        @Published fileprivate private(set) var featureTemplateSections = [FeatureTemplateSectionInfo]()
        /// A Boolean value indicating whether templates are being generated.
        @Published var isGeneratingFeatureTemplates = false
        /// A Boolean value indicating if content is unavailable.
        @Published var showContentUnavailable = false
        /// A Boolean value indicating if no templates were found with the given search text.
        @Published var showNoTemplatesFound = false
        
        /// Creates a model for a given geo model.
        init(geoModel: GeoModel, includeNonCreatableFeatureTemplates: Bool) {
            self.geoModel = geoModel
            self.includeNonCreatableFeatureTemplates = includeNonCreatableFeatureTemplates
        }
        
        /// Generates the feature templates.
        func generateFeatureTemplates() async {
            isGeneratingFeatureTemplates = true
            defer { isGeneratingFeatureTemplates = false }
            
            unfilteredFeatureTemplateSections = await makeFeatureTemplateSections()
        }
        
        /// The feature template section information for the geo model.
        private func makeFeatureTemplateSections() async -> [FeatureTemplateSectionInfo] {
            try? await geoModel.load()
            var sections = [FeatureTemplateSectionInfo]()
            let layersAndTables = geoModel.arcGISFeatureLayersAndTables
            await layersAndTables.map(\.table).load()
            for (layer, table) in layersAndTables {
                guard includeNonCreatableFeatureTemplates || table.canAddFeature else { continue }
                var infos = [FeatureTemplateInfo]()
                for template in table.allTemplates {
                    let feature = table.makeFeature(template: template)
                    let symbol = layer.renderer?.symbol(for: feature)
                    let image = try? await symbol?.makeSwatch(scale: UIScreen.main.scale)
                    infos.append(
                        FeatureTemplateInfo(
                            layer: layer,
                            table: table,
                            template: template,
                            image: image
                        )
                    )
                }
                sections.append(
                    .init(table: table, infos: infos)
                )
            }
            return sections.filter { !$0.infos.isEmpty }
        }
        
        /// Re-filters based on the templates or the search text.
        private func templatesOrSearchTextDidChange() {
            featureTemplateSections = unfilteredFeatureTemplateSections.map {
                $0.filtered(by: searchText)
            }
            .filter { !$0.infos.isEmpty }
            showContentUnavailable = unfilteredFeatureTemplateSections.isEmpty
            showNoTemplatesFound = !showContentUnavailable && featureTemplateSections.isEmpty
        }
    }
}

private extension Array<Layer> {
    /// A flattened list of the nested layers that this array of layers may contain.
    var flattened: [Layer] {
        flatMap { layer in
            guard let groupLayer = layer as? GroupLayer else { return [layer] }
            return groupLayer.layers.flattened
        }
    }
}

private extension GeoModel {
    /// All the layers in the geo model.
    var layers: [Layer] {
        operationalLayers
        + (basemap?.baseLayers ?? [])
        + (basemap?.referenceLayers ?? [])
    }
    
    /// A flattened list of the layers in the geo model.
    var flattenedLayers: [Layer] {
        layers.flattened
    }
    
    /// All the feature layers in the geo model.
    var featureLayers: [FeatureLayer] {
        flattenedLayers
            .compactMap { $0 as? FeatureLayer }
    }
    
    /// A list containing tuples of the feature layers and the associated
    /// ArcGIS feature tables in the geo model.
    var arcGISFeatureLayersAndTables: [(layer: FeatureLayer, table: ArcGISFeatureTable)] {
        featureLayers
            .map { (layer: $0, table: $0.featureTable) }
            .compactMap { tuple in
                if let table = tuple.table as? ArcGISFeatureTable {
                    return (layer: tuple.layer, table: table)
                } else {
                    return nil
                }
            }
    }
}

private extension ArcGISFeatureTable {
    /// A flattened list of the feature templates in the table.
    var allTemplates: [FeatureTemplate] {
        let typeTemplates = featureTypes
            .lazy
            .flatMap { $0.templates }
        return featureTemplates + typeTemplates
    }
}

/// A value that represents a section in the feature template picker.
private struct FeatureTemplateSectionInfo: Identifiable {
    let table: ArcGISFeatureTable
    var infos: [FeatureTemplateInfo]
    let id: UUID = UUID()
    
    func filtered(by searchText: String) -> FeatureTemplateSectionInfo {
        guard !searchText.isEmpty else { return self }
        var copy = self
        copy.infos = copy.infos.filter { $0.template.name.lowercased().contains(searchText.lowercased()) }
        return copy
    }
}

/// A value that represents a feature template in the picker.
public struct FeatureTemplateInfo: Identifiable, Equatable {
    public static func == (lhs: FeatureTemplateInfo, rhs: FeatureTemplateInfo) -> Bool {
        lhs.template === rhs.template
    }
    
    let layer: FeatureLayer
    let table: ArcGISFeatureTable
    let template: FeatureTemplate
    let image: UIImage?
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(template)
    }
}
