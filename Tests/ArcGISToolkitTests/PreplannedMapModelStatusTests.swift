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

import XCTest
***REMOVED***
@testable ***REMOVED***Toolkit

class PreplannedMapModelStatusTests: XCTestCase {
***REMOVED***private typealias Status = PreplannedMapModel.Status
***REMOVED***
***REMOVED***func testCanLoadPreplannedMapArea() {
***REMOVED******REMOVED***XCTAssertFalse(Status.loading.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.packaging.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.packaged.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloading.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloaded.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadFailure(CancellationError()).canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertTrue(Status.notLoaded.canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertTrue(Status.loadFailure(CancellationError()).canLoadPreplannedMapArea)
***REMOVED******REMOVED***XCTAssertTrue(Status.packageFailure.canLoadPreplannedMapArea)
***REMOVED***
***REMOVED***
***REMOVED***func testAllowsDownload() {
***REMOVED******REMOVED***XCTAssertFalse(Status.notLoaded.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.loading.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.loadFailure(CancellationError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.packaging.allowsDownload)
***REMOVED******REMOVED***XCTAssertTrue(Status.packaged.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.packageFailure.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloading.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloaded.allowsDownload)
***REMOVED******REMOVED***XCTAssertTrue(Status.downloadFailure(CancellationError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).allowsDownload)
***REMOVED***
***REMOVED***
***REMOVED***func testIsDownloaded() {
***REMOVED******REMOVED***XCTAssertFalse(Status.notLoaded.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.loading.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.loadFailure(CancellationError()).isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.packaging.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.packaged.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.packageFailure.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloading.isDownloaded)
***REMOVED******REMOVED***XCTAssertTrue(Status.downloaded.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadFailure(CancellationError()).isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).isDownloaded)
***REMOVED***
***REMOVED***
