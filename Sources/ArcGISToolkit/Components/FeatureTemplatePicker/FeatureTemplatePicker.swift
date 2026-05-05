// Copyright 2026 Esri
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

public extension View {
    func featureTemplatePicker(
        _ templates: [[Int: [SharedTemplate]]],
        isPresented: Binding<Bool>,
        geometryEditor: GeometryEditor,
    ) -> some View {
        inspector(
            // Workaround for bug where inspector sometimes sets binding on init
            // which prevents it for appear when the binding is later set.
            isPresented: isPresented.wrappedValue ? isPresented : .constant(false)
        ) {
            FeatureTemplatePicker(results: templates, geometryEditor: geometryEditor)
                .inspectorColumnWidth(min: 320, ideal: 320, max: 320)
                .interactiveDismissDisabled()
                .environment(\.isPresented, isPresented)
        }
    }
}

private struct FeatureTemplatePicker: View {
    let results: [[Int: [SharedTemplate]]]
    let geometryEditor: GeometryEditor
    
    @Environment(\.isPresented) private var isPresented
    
    @State private var groupItems: [TemplatePickerGroupItem]?
    @State private var navigationPath = NavigationPath()
    @State private var searchText = _DebugSettings.templatePickerSearch
    
    private var filteredGroupItems: [TemplatePickerGroupItem]? {
        if searchText.isEmpty {
            groupItems
        } else {
            groupItems?.reduce(into: []) { result, groupItem in
                if groupItem.name.localizedStandardContains(searchText) {
                    result.append(groupItem)
                } else {
                    let templateItems = groupItem.templateItems
                        .filter { $0.template.name.localizedStandardContains(searchText) }
                    guard !templateItems.isEmpty else { return }
                    
                    result.append(
                        TemplatePickerGroupItem(name: groupItem.name, templateItems: templateItems)
                    )
                }
            }
        }
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let filteredGroupItems {
                    List {
                        if !filteredGroupItems.isEmpty {
                            ForEach(filteredGroupItems, id: \.self) { groupItem in
                                TemplatePickerSection(item: groupItem)
                            }
                        } else {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                    .listStyle(.sidebar)
                    .navigationDestination(for: TemplatePickerItem.self) { templateItem in
                        GeometryConstructionToolPicker(
                            templateItem: templateItem,
                            geometryEditor: geometryEditor
                        )
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            DismissButton(kind: .close) { isPresented?.wrappedValue = false }
                        }
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                } else {
                    ProgressView("Loading templates")
                }
            }
            .navigationTitle("Create Features")
            .task(id: results, setUp)
        }
        .environment(\.navigationPath, $navigationPath)
        .onChange(of: isPresented?.wrappedValue) {
            guard let isPresented, !isPresented.wrappedValue else { return }
            navigationPath.removeLast(navigationPath.count)
            searchText = ""
        }
    }
    
    private func setUp() async {
        guard !results.isEmpty else { return }
        
        groupItems = await makeGroupItems(from: results)
        print(
            "groupItems: \(groupItems!.count)",
            "templateItems: \(groupItems!.reduce(0, { $0 + $1.templateItems.count }))"
        )
        
        if _DebugSettings.openTemplate {
            _DebugSettings.openTemplate = false
            let _groupItem = groupItems?
                .first(where: { $0.name == _DebugSettings.selectedGroupItem })?.templateItems
                .first(where: { $0.template.name == _DebugSettings.selectedTemplateItem })
            navigationPath.append(_groupItem!)
        }
        
        for groupItem in groupItems! {
            for templateItem in groupItem.templateItems {
                try? await templateItem.loadImage()
            }
        }
    }
    
    private func makeGroupItems(
        from results: [[Int: [SharedTemplate]]]
    ) async -> [TemplatePickerGroupItem] {
        return await withTaskGroup(of: TemplatePickerGroupItem?.self) { taskGroup in
            for templates in results {
                guard let source = templates.values.first?.first?.source else { continue }
                
                for (layerID, layerTemplates) in templates {
                    taskGroup.addTask { @Sendable in
                        let featureTable = source.featureTable(withLayerID: layerID)!
                        
                        try! await featureTable.load()
                        guard featureTable.hasGeometry, !layerTemplates.isEmpty else { return nil }
                        
                        let templateItems = layerTemplates
                            .map { TemplatePickerItem($0, layerID: layerID) }
                            .sorted { $0.template.name < $1.template.name }
                        
                        let groupName = featureTable.displayName
                        return TemplatePickerGroupItem(name: groupName, templateItems: templateItems)
                    }
                }
            }
            
            var groupItems: [TemplatePickerGroupItem] = []
            for await groupItem in taskGroup {
                guard let groupItem else { continue }
                groupItems.append(groupItem)
            }
            
            return groupItems.sorted { $0.name < $1.name }
        }
    }
}

private struct TemplatePickerSection: View {
    let item: TemplatePickerGroupItem
    
    @State private var isExpanded = true
    
    var body: some View {
        Section(item.name, isExpanded: $isExpanded) {
            ForEach(item.templateItems, id: \.self) { templateItem in
                NavigationLink(value: templateItem) {
                    TemplatePickerItemLabel(item: templateItem)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TemplatePickerGroupItem: Hashable, Sendable {
    let name: String
    let templateItems: [TemplatePickerItem]
}


// MARK: - Extensions

extension SharedTemplate: Hashable {}
