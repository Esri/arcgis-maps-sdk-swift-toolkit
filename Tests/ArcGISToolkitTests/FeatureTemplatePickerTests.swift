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
@testable ***REMOVED***Toolkit
import Foundation
import os
import Testing

@Suite("FeatureTemplatePicker Tests")
struct FeatureTemplatePickerTests {
***REMOVED***@Test
***REMOVED***@MainActor
***REMOVED***func testGeoModelWithTemplates() async throws {
***REMOVED******REMOVED***let map = makeMapWithTemplates()
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = FeatureTemplatePicker.Model(geoModel: map, includeNonCreatableFeatureTemplates: true)
***REMOVED******REMOVED***#expect(model.includeNonCreatableFeatureTemplates)
***REMOVED******REMOVED***#expect(!model.isGeneratingFeatureTemplates)
***REMOVED******REMOVED***#expect(!model.showContentUnavailable)
***REMOVED******REMOVED***#expect(!model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let lockedValues = OSAllocatedUnfairLock(initialState: Array<Bool>())
***REMOVED******REMOVED***let subscription = model.$isGeneratingFeatureTemplates.sink { isGeneratingFeatureTemplates in
***REMOVED******REMOVED******REMOVED***lockedValues.withLock { $0.append(isGeneratingFeatureTemplates) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***#expect(model.featureTemplateSections.isEmpty)
***REMOVED******REMOVED***await model.generateFeatureTemplates()
***REMOVED******REMOVED***#expect(model.featureTemplateSections.count == 1)
***REMOVED******REMOVED***if let section = model.featureTemplateSections.first {
***REMOVED******REMOVED******REMOVED***#expect(section.infos.count == 5)
***REMOVED***
***REMOVED******REMOVED***#expect(!model.showContentUnavailable)
***REMOVED******REMOVED***#expect(!model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.searchText = "foo"
***REMOVED******REMOVED***#expect(!model.showContentUnavailable)
***REMOVED******REMOVED***#expect(model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let values = lockedValues.withLock { $0 ***REMOVED***
***REMOVED******REMOVED***#expect(values == [false, true, false])
***REMOVED***
***REMOVED***
***REMOVED***@Test
***REMOVED***@MainActor
***REMOVED***func testGeoModelNoTemplates() async throws {
***REMOVED******REMOVED***let map = Map(spatialReference: .webMercator)
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = FeatureTemplatePicker.Model(geoModel: map, includeNonCreatableFeatureTemplates: false)
***REMOVED******REMOVED***#expect(!model.includeNonCreatableFeatureTemplates)
***REMOVED******REMOVED***#expect(!model.isGeneratingFeatureTemplates)
***REMOVED******REMOVED***#expect(!model.showContentUnavailable)
***REMOVED******REMOVED***#expect(!model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let lockedValues = OSAllocatedUnfairLock(initialState: Array<Bool>())
***REMOVED******REMOVED***let subscription = model.$isGeneratingFeatureTemplates.sink { isGeneratingFeatureTemplates in
***REMOVED******REMOVED******REMOVED***lockedValues.withLock { $0.append(isGeneratingFeatureTemplates) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***#expect(model.featureTemplateSections.isEmpty)
***REMOVED******REMOVED***await model.generateFeatureTemplates()
***REMOVED******REMOVED***#expect(model.featureTemplateSections.isEmpty)
***REMOVED******REMOVED***#expect(model.showContentUnavailable)
***REMOVED******REMOVED***#expect(!model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.searchText = "foo"
***REMOVED******REMOVED***#expect(model.showContentUnavailable)
***REMOVED******REMOVED***#expect(!model.showNoTemplatesFound)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let values = lockedValues.withLock { $0 ***REMOVED***
***REMOVED******REMOVED***#expect(values == [false, true, false])
***REMOVED***
***REMOVED***

private func makeMapWithTemplates() -> Map {
***REMOVED***let map = Map(spatialReference: .webMercator)
***REMOVED***let featureTable = ServiceFeatureTable(url: URL(string: "https:***REMOVED***sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
***REMOVED***let featureLayer = FeatureLayer(featureTable: featureTable)
***REMOVED***map.addOperationalLayer(featureLayer)
***REMOVED***return map
***REMOVED***
