***REMOVED***
***REMOVED***  CompassTests 2.swift
***REMOVED***  arcgis-maps-sdk-swift-toolkit
***REMOVED***
***REMOVED***  Created by Ryan Olson on 12/31/24.
***REMOVED***


***REMOVED*** Copyright 2022 Esri
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
***REMOVED***
import Testing

@Suite("FeatureTemplatePicker Tests")
struct FeatureTemplatePickerTests {
***REMOVED***@Test
***REMOVED***@MainActor
***REMOVED***func testModel() async throws {
***REMOVED******REMOVED***let map = makeMap()
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = FeatureTemplatePicker.Model(geoModel: map, includeNonCreatableFeatureTemplates: true)
***REMOVED******REMOVED***#expect(model.includeNonCreatableFeatureTemplates == true)
***REMOVED******REMOVED***#expect(model.isGeneratingFeatureTemplates == false)
***REMOVED******REMOVED***#expect(model.showContentUnavailable == false)
***REMOVED******REMOVED***#expect(model.showNoTemplatesFound == false)
***REMOVED***
***REMOVED***

private func makeMap() -> Map {
***REMOVED***let map = Map(spatialReference: .webMercator)
***REMOVED***let featureTable = ServiceFeatureTable(url: URL(string: "https:***REMOVED***sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0")!)
***REMOVED***let featureLayer = FeatureLayer(featureTable: featureTable)
***REMOVED***map.addOperationalLayer(featureLayer)
***REMOVED***return map
***REMOVED***
