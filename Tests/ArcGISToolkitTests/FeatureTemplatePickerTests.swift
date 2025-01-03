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
@testable import ArcGISToolkit
import Foundation
import os
import Testing

@Suite("FeatureTemplatePicker Tests")
struct FeatureTemplatePickerTests {
    @Test
    @MainActor
    func testGeoModelWithTemplates() async throws {
        let map = makeMapWithTemplates()
        try await map.load()
        
        let model = FeatureTemplatePicker.Model(geoModel: map, includeNonCreatableFeatureTemplates: true)
        #expect(model.includeNonCreatableFeatureTemplates)
        #expect(!model.isGeneratingFeatureTemplates)
        #expect(!model.showContentUnavailable)
        #expect(!model.showNoTemplatesFound)
        
        let lockedValues = OSAllocatedUnfairLock(initialState: Array<Bool>())
        let subscription = model.$isGeneratingFeatureTemplates.sink { isGeneratingFeatureTemplates in
            lockedValues.withLock { $0.append(isGeneratingFeatureTemplates) }
        }
        
        #expect(model.featureTemplateSections.isEmpty)
        await model.generateFeatureTemplates()
        #expect(model.featureTemplateSections.count == 1)
        if let section = model.featureTemplateSections.first {
            #expect(section.infos.count == 5)
        }
        #expect(!model.showContentUnavailable)
        #expect(!model.showNoTemplatesFound)
        
        model.searchText = "foo"
        #expect(!model.showContentUnavailable)
        #expect(model.showNoTemplatesFound)
        
        let values = lockedValues.withLock { $0 }
        #expect(values == [false, true, false])
        
        subscription.cancel()
    }
    
    @Test
    @MainActor
    func testGeoModelNoTemplates() async throws {
        let map = Map(spatialReference: .webMercator)
        try await map.load()
        
        let model = FeatureTemplatePicker.Model(geoModel: map, includeNonCreatableFeatureTemplates: false)
        #expect(!model.includeNonCreatableFeatureTemplates)
        #expect(!model.isGeneratingFeatureTemplates)
        #expect(!model.showContentUnavailable)
        #expect(!model.showNoTemplatesFound)
        
        let lockedValues = OSAllocatedUnfairLock(initialState: Array<Bool>())
        let subscription = model.$isGeneratingFeatureTemplates.sink { isGeneratingFeatureTemplates in
            lockedValues.withLock { $0.append(isGeneratingFeatureTemplates) }
        }
        
        #expect(model.featureTemplateSections.isEmpty)
        await model.generateFeatureTemplates()
        #expect(model.featureTemplateSections.isEmpty)
        #expect(model.showContentUnavailable)
        #expect(!model.showNoTemplatesFound)
        
        model.searchText = "foo"
        #expect(model.showContentUnavailable)
        #expect(!model.showNoTemplatesFound)
        
        let values = lockedValues.withLock { $0 }
        #expect(values == [false, true, false])
        
        subscription.cancel()
    }
}

private func makeMapWithTemplates() -> Map {
    let map = Map(spatialReference: .webMercator)
    let featureTable = ServiceFeatureTable(url: URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
    let featureLayer = FeatureLayer(featureTable: featureTable)
    map.addOperationalLayer(featureLayer)
    return map
}
