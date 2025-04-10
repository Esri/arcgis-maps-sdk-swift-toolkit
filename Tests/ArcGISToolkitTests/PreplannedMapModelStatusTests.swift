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
    private typealias Status = PreplannedMapModel.Status
    
    func testCanLoadPreplannedMapArea() {
        XCTAssertFalse(Status.loading.canLoadPreplannedMapArea)
        XCTAssertFalse(Status.packaging.canLoadPreplannedMapArea)
        XCTAssertFalse(Status.packaged.canLoadPreplannedMapArea)
        XCTAssertFalse(Status.downloading.canLoadPreplannedMapArea)
        XCTAssertFalse(Status.downloaded.canLoadPreplannedMapArea)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).canLoadPreplannedMapArea)
        XCTAssertFalse(Status.downloadFailure(CancellationError()).canLoadPreplannedMapArea)
        XCTAssertFalse(Status.downloadCancelled.canLoadPreplannedMapArea)
        XCTAssertTrue(Status.notLoaded.canLoadPreplannedMapArea)
        XCTAssertTrue(Status.loadFailure(CancellationError()).canLoadPreplannedMapArea)
        XCTAssertTrue(Status.packageFailure.canLoadPreplannedMapArea)
    }
    
    func testAllowsDownload() {
        XCTAssertFalse(Status.notLoaded.allowsDownload)
        XCTAssertFalse(Status.loading.allowsDownload)
        XCTAssertFalse(Status.loadFailure(CancellationError()).allowsDownload)
        XCTAssertFalse(Status.packaging.allowsDownload)
        XCTAssertTrue(Status.packaged.allowsDownload)
        XCTAssertFalse(Status.packageFailure.allowsDownload)
        XCTAssertFalse(Status.downloading.allowsDownload)
        XCTAssertFalse(Status.downloaded.allowsDownload)
        XCTAssertTrue(Status.downloadFailure(CancellationError()).allowsDownload)
        XCTAssertTrue(Status.downloadCancelled.allowsDownload)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).allowsDownload)
    }
    
    func testIsDownloaded() {
        XCTAssertFalse(Status.notLoaded.isDownloaded)
        XCTAssertFalse(Status.loading.isDownloaded)
        XCTAssertFalse(Status.loadFailure(CancellationError()).isDownloaded)
        XCTAssertFalse(Status.packaging.isDownloaded)
        XCTAssertFalse(Status.packaged.isDownloaded)
        XCTAssertFalse(Status.packageFailure.isDownloaded)
        XCTAssertFalse(Status.downloading.isDownloaded)
        XCTAssertTrue(Status.downloaded.isDownloaded)
        XCTAssertFalse(Status.downloadFailure(CancellationError()).isDownloaded)
        XCTAssertFalse(Status.downloadCancelled.isDownloaded)
        XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).isDownloaded)
    }
}
