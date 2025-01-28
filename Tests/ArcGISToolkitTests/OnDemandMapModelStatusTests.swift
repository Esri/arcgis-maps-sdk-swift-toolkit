// Copyright 2025 Esri
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

class OnDemandMapModelStatusTests: XCTestCase {
    private typealias Status = OnDemandMapModel.Status
    
    func testNeedsToBeLoaded() {
        XCTAssertTrue(Status.initialized.needsToBeLoaded)
        XCTAssertFalse(Status.downloading.needsToBeLoaded)
        XCTAssertFalse(Status.downloaded.needsToBeLoaded)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).needsToBeLoaded)
        XCTAssertTrue(Status.downloadFailure(CancellationError()).needsToBeLoaded)
    }
    
    func testAllowsDownload() {
        XCTAssertTrue(Status.initialized.allowsDownload)
        XCTAssertFalse(Status.downloading.allowsDownload)
        XCTAssertFalse(Status.downloaded.allowsDownload)
        XCTAssertTrue(Status.downloadFailure(CancellationError()).allowsDownload)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).allowsDownload)
    }
    
    func testIsDownloaded() {
        XCTAssertFalse(Status.initialized.isDownloaded)
        XCTAssertFalse(Status.downloading.isDownloaded)
        XCTAssertTrue(Status.downloaded.isDownloaded)
        XCTAssertFalse(Status.downloadFailure(CancellationError()).isDownloaded)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).isDownloaded)
    }
}
