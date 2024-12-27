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

public struct FeatureTemplatePicker: View {
    /// The model backing the feature template picker.
    @StateObject var model: Model
    @Binding var selection: FeatureTemplateInfo?
    
    init(geoModel: GeoModel, selection: Binding<FeatureTemplateInfo?>) {
        _model = StateObject(wrappedValue: Model(geoModel: geoModel))
        _selection = selection
    }
    
    public var body: some View {
        Group {
            if model.isGeneratingFeatureTemplates {
                ProgressView()
            } else if model.showContentUnavailable {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(
                        "No Feature Templates",
                        systemImage: "list.bullet",
                        description: Text("No feature templates available for this map.")
                    )
                } else {
                    // Fallback on earlier versions
                    Text("No feature templates available for this map.")
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
            }
        }
        .task {
            await model.generateFeatureTemplates()
        }
    }
}

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
    /// The model for the legend.
    @MainActor
    final class Model: ObservableObject {
        /// The associated geo model.
        let geoModel: GeoModel
        
        /// The templates.
        @Published fileprivate var featureTemplateSections = [FeatureTemplateSectionInfo]()
        @Published var isGeneratingFeatureTemplates = false
        @Published var showContentUnavailable = false
        
        /// Creates a model for a given geo model.
        init(geoModel: GeoModel) {
            self.geoModel = geoModel
        }
        
        /// Generates the feature templates.
        func generateFeatureTemplates() async {
            isGeneratingFeatureTemplates = true
            defer { isGeneratingFeatureTemplates = false }
            
            featureTemplateSections = await geoModel.featureTemplateSections
        }
    }
}

extension GeoModel {
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

private extension GeoModel {
    var featureTemplateSections: [FeatureTemplateSectionInfo] {
        get async {
            var sections = [FeatureTemplateSectionInfo]()
            for (layer, table) in self.arcGISFeatureLayersAndTables {
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
            return sections
        }
    }
}

extension ArcGISFeatureTable {
    var allTemplates: [FeatureTemplate] {
        let typeTemplates = featureTypes
            .lazy
            .flatMap { $0.templates }
        return featureTemplates + typeTemplates
    }
}

private struct FeatureTemplateSectionInfo: Identifiable {
    let table: ArcGISFeatureTable
    let infos: [FeatureTemplateInfo]
    
    var id: ObjectIdentifier {
        ObjectIdentifier(table)
    }
}

struct FeatureTemplateInfo: Identifiable, Equatable {
    static func == (lhs: FeatureTemplateInfo, rhs: FeatureTemplateInfo) -> Bool {
        lhs.template === rhs.template
    }
    
    let layer: FeatureLayer
    let table: ArcGISFeatureTable
    let template: FeatureTemplate
    let image: UIImage?
    
    var id: ObjectIdentifier {
        ObjectIdentifier(template)
    }
}
