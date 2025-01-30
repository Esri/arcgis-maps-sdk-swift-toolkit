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
import XCTest

final class FeatureFormTests: XCTestCase {
    func testLoadAttachment() async throws {
        let _url = 
        let _user =
        let _pass =
        
        let credential = try await TokenCredential.credential(
            for: URL(string: "https://www.arcgis.com")!,
            username: _user,
            password: _pass
        )
        
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        
        let map = Map(url: URL(string: _url)!)!
        try await XCTLoad(map)
        
        // Load layer and table
        let featureLayer = try XCTUnwrap(map.operationalLayers.first as? FeatureLayer)
        try await XCTLoad(featureLayer)
        let table = try XCTUnwrap(featureLayer.featureTable)
        try await XCTLoad(table)
        
        // Get feature of interest
        let queryParameters = QueryParameters()
        queryParameters.addObjectID(1)
        let queryResult = try await table.queryFeatures(using: queryParameters)
        let features = Array(queryResult.features())
        let feature = try XCTUnwrap(features.first as? ArcGISFeature)
        
        // Build feature form
        let featureForm = FeatureForm(feature: feature)
        try await featureForm.evaluateExpressions()
        
        // Get attachment, create model
        let attachmentFormElement = try XCTUnwrap(featureForm.defaultAttachmentsElement)
        let attachment = try await XCTUnwrapAsync(await attachmentFormElement.attachments.first)
        let model = await AttachmentModel(attachment: attachment, displayScale: 1, thumbnailSize: CGSize.zero)
        
        print(attachment.name, attachment.loadStatus)
        await print(model.name, model.loadStatus)
        
        print("Start load")
        await model.load() // <= Thread 1: EXC_BAD_ACCESS (code=1, address=0x18)
        
        print(attachment.name, attachment.loadStatus)
        await print(model.name, model.loadStatus)
    }
}

func XCTLoad<Loadable>(
    _ loadable: Loadable,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws where Loadable: ArcGIS.Loadable {
    do {
        try await loadable.load()
    } catch {
        XCTFail("\"\(error)\"", file: file, line: line)
        throw error
    }
    XCTAssertEqual(loadable.loadStatus, .loaded, file: file, line: line)
    XCTAssertNil(loadable.loadError, file: file, line: line)
}

func XCTUnwrapAsync<T>(
    _ expression: @autoclosure @Sendable () async throws -> T?,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> T {
    let value = try await expression()
    return try XCTUnwrap(value, file: file, line: line)
}
