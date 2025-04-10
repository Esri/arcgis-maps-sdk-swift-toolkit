***REMOVED*** Copyright 2025 Esri
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

class OnDemandMapModelStatusTests: XCTestCase {
***REMOVED***private typealias Status = OnDemandMapModel.Status
***REMOVED***
***REMOVED***func testAllowsDownload() {
***REMOVED******REMOVED***XCTAssertTrue(Status.initialized.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloading.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloaded.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadFailure(CancellationError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadCancelled.allowsDownload)
***REMOVED***
***REMOVED***
***REMOVED***func testIsDownloaded() {
***REMOVED******REMOVED***XCTAssertFalse(Status.initialized.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloading.isDownloaded)
***REMOVED******REMOVED***XCTAssertTrue(Status.downloaded.isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadFailure(CancellationError()).isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.mmpkLoadFailure(CancellationError()).isDownloaded)
***REMOVED******REMOVED***XCTAssertFalse(Status.downloadCancelled.isDownloaded)
***REMOVED***
***REMOVED***
