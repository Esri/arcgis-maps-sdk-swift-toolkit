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
***REMOVED***func testNeedsToBeLoaded() {
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.loading.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.packaging.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.packaged.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.downloading.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.downloaded.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.mmpkLoadFailure(NSError()).needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.notLoaded.needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.downloadFailure(NSError()).needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.loadFailure(NSError()).needsToBeLoaded)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.packageFailure.needsToBeLoaded)
***REMOVED***
***REMOVED***
***REMOVED***func testAllowsDownload() {
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.notLoaded.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.loading.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.loadFailure(NSError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.packaging.allowsDownload)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.packaged.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.packageFailure.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.downloading.allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.downloaded.allowsDownload)
***REMOVED******REMOVED***XCTAssertTrue(PreplannedMapModel.Status.downloadFailure(NSError()).allowsDownload)
***REMOVED******REMOVED***XCTAssertFalse(PreplannedMapModel.Status.mmpkLoadFailure(NSError()).allowsDownload)
***REMOVED***
***REMOVED***
