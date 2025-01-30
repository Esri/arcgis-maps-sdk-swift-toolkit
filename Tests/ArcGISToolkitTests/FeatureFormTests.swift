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
import XCTest

final class FeatureFormTests: XCTestCase {
***REMOVED***func testLoadAttachment() async throws {
***REMOVED******REMOVED***let _url = 
***REMOVED******REMOVED***let _user =
***REMOVED******REMOVED***let _pass =
***REMOVED******REMOVED***
***REMOVED******REMOVED***let credential = try await TokenCredential.credential(
***REMOVED******REMOVED******REMOVED***for: URL(string: "https:***REMOVED***www.arcgis.com")!,
***REMOVED******REMOVED******REMOVED***username: _user,
***REMOVED******REMOVED******REMOVED***password: _pass
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let map = Map(url: URL(string: _url)!)!
***REMOVED******REMOVED***try await XCTLoad(map)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Load layer and table
***REMOVED******REMOVED***let featureLayer = try XCTUnwrap(map.operationalLayers.first as? FeatureLayer)
***REMOVED******REMOVED***try await XCTLoad(featureLayer)
***REMOVED******REMOVED***let table = try XCTUnwrap(featureLayer.featureTable)
***REMOVED******REMOVED***try await XCTLoad(table)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get feature of interest
***REMOVED******REMOVED***let queryParameters = QueryParameters()
***REMOVED******REMOVED***queryParameters.addObjectID(1)
***REMOVED******REMOVED***let queryResult = try await table.queryFeatures(using: queryParameters)
***REMOVED******REMOVED***let features = Array(queryResult.features())
***REMOVED******REMOVED***let feature = try XCTUnwrap(features.first as? ArcGISFeature)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Build feature form
***REMOVED******REMOVED***let featureForm = FeatureForm(feature: feature)
***REMOVED******REMOVED***try await featureForm.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get attachment, create model
***REMOVED******REMOVED***let attachmentFormElement = try XCTUnwrap(featureForm.defaultAttachmentsElement)
***REMOVED******REMOVED***let attachment = try await XCTUnwrapAsync(await attachmentFormElement.attachments.first)
***REMOVED******REMOVED***let model = await AttachmentModel(attachment: attachment, displayScale: 1, thumbnailSize: CGSize.zero)
***REMOVED******REMOVED***
***REMOVED******REMOVED***print(attachment.name, attachment.loadStatus)
***REMOVED******REMOVED***await print(model.name, model.loadStatus)
***REMOVED******REMOVED***
***REMOVED******REMOVED***print("Start load")
***REMOVED******REMOVED***await model.load() ***REMOVED*** <= Thread 1: EXC_BAD_ACCESS (code=1, address=0x18)
***REMOVED******REMOVED***
***REMOVED******REMOVED***print(attachment.name, attachment.loadStatus)
***REMOVED******REMOVED***await print(model.name, model.loadStatus)
***REMOVED***
***REMOVED***

func XCTLoad<Loadable>(
***REMOVED***_ loadable: Loadable,
***REMOVED***file: StaticString = #filePath,
***REMOVED***line: UInt = #line
) async throws where Loadable: ArcGIS.Loadable {
***REMOVED***do {
***REMOVED******REMOVED***try await loadable.load()
***REMOVED*** catch {
***REMOVED******REMOVED***XCTFail("\"\(error)\"", file: file, line: line)
***REMOVED******REMOVED***throw error
***REMOVED***
***REMOVED***XCTAssertEqual(loadable.loadStatus, .loaded, file: file, line: line)
***REMOVED***XCTAssertNil(loadable.loadError, file: file, line: line)
***REMOVED***

func XCTUnwrapAsync<T>(
***REMOVED***_ expression: @autoclosure @Sendable () async throws -> T?,
***REMOVED***file: StaticString = #filePath,
***REMOVED***line: UInt = #line
) async throws -> T {
***REMOVED***let value = try await expression()
***REMOVED***return try XCTUnwrap(value, file: file, line: line)
***REMOVED***
