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

import XCTest
import ArcGIS
@testable import ArcGISToolkit

class PreplannedMapModelStatusTests: XCTestCase {
    func testNeedsToBeLoaded() {
        XCTAssertFalse(PreplannedMapModel.Status.loading.needsToBeLoaded)
        XCTAssertFalse(PreplannedMapModel.Status.packaging.needsToBeLoaded)
        XCTAssertFalse(PreplannedMapModel.Status.packaged.needsToBeLoaded)
        XCTAssertFalse(PreplannedMapModel.Status.downloading.needsToBeLoaded)
        XCTAssertFalse(PreplannedMapModel.Status.downloaded.needsToBeLoaded)
        XCTAssertTrue(PreplannedMapModel.Status.notLoaded.needsToBeLoaded)
        XCTAssertTrue(PreplannedMapModel.Status.downloadFailure(NSError()).needsToBeLoaded)
        XCTAssertTrue(PreplannedMapModel.Status.loadFailure(NSError()).needsToBeLoaded)
        XCTAssertTrue(PreplannedMapModel.Status.packageFailure.needsToBeLoaded)
    }
    
    func testAllowsDownload() {
        XCTAssertFalse(PreplannedMapModel.Status.notLoaded.allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.loading.allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.loadFailure(NSError()).allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.packaging.allowsDownload)
        XCTAssertTrue(PreplannedMapModel.Status.packaged.allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.packageFailure.allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.downloading.allowsDownload)
        XCTAssertFalse(PreplannedMapModel.Status.downloaded.allowsDownload)
        XCTAssertTrue(PreplannedMapModel.Status.downloadFailure(NSError()).allowsDownload)
    }
}
