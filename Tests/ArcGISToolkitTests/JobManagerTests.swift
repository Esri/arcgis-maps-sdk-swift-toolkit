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
import XCTest
@testable ***REMOVED***Toolkit

final class JobManagerTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***let jobManager = JobManager(id: "test")
***REMOVED******REMOVED***XCTAssertEqual(jobManager.id, "test")
***REMOVED******REMOVED***XCTAssertEqual(jobManager.defaultsKey, "com.esri.ArcGISToolkit.jobManager.test.jobs")
***REMOVED******REMOVED***XCTAssertEqual(jobManager.statusChecksTaskIdentifier, "com.esri.ArcGISToolkit.jobManager.test.statusCheck")
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testShared() {
***REMOVED******REMOVED***let jobManager = JobManager.shared
***REMOVED******REMOVED***XCTAssertNil(jobManager.id)
***REMOVED******REMOVED***XCTAssertEqual(jobManager.defaultsKey, "com.esri.ArcGISToolkit.jobManager.jobs")
***REMOVED******REMOVED***XCTAssertEqual(jobManager.statusChecksTaskIdentifier, "com.esri.ArcGISToolkit.jobManager.statusCheck")
***REMOVED***
***REMOVED***
