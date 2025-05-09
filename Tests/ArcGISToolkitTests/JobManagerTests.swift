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
@testable import ArcGISToolkit

final class JobManagerTests: XCTestCase {
    @MainActor
    func testInit() {
        let jobManager = JobManager(uniqueID: "test")
        XCTAssertEqual(jobManager.id, "test")
        XCTAssertEqual(jobManager.defaultsKey, "com.esri.ArcGISToolkit.jobManager.test.jobs")
        XCTAssertEqual(jobManager.statusChecksTaskIdentifier, "com.esri.ArcGISToolkit.jobManager.test.statusCheck")
    }
    
    @MainActor
    func testShared() {
        let jobManager = JobManager.shared
        XCTAssertNil(jobManager.id)
        XCTAssertEqual(jobManager.defaultsKey, "com.esri.ArcGISToolkit.jobManager.jobs")
        XCTAssertEqual(jobManager.statusChecksTaskIdentifier, "com.esri.ArcGISToolkit.jobManager.statusCheck")
    }
}
