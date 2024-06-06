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

private extension PreplannedMapAreaProtocol {
    var packagingStatus: PreplannedMapArea.PackagingStatus? { nil }
    var title: String { "Mock Preplanned Map Area" }
    var description: String { "This is the description text" }
    var thumbnail: ArcGIS.LoadableImage? { nil }
}

class PreplannedMapModelTests: XCTestCase {
    private static var sleepNanoseconds: UInt64 { 1_000_000 }
    
    @MainActor
    func testInit() {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        XCTAssertIdentical(model.preplannedMapArea as? MockPreplannedMapArea, mockArea)
    }
    
    @MainActor
    func testInitialStatus() {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        guard case .notLoaded = model.status else {
            XCTFail("PreplannedMapModel initial status is not \".notLoaded\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertTrue(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testLoadingStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws {
                // In `retryLoad` method, simulate a time-consuming `load` method,
                // so the model status stays at "loading".
                try await Task.sleep(nanoseconds: 2 * PreplannedMapModelTests.sleepNanoseconds)
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        Task { await model.load() }
        try await Task.sleep(nanoseconds: PreplannedMapModelTests.sleepNanoseconds)
        guard case .loading = model.status else {
            XCTFail("PreplannedMapModel status is not \".loading\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertFalse(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testNilPackagingStatus() async throws {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        
        // Packaging status is `nil` for compatibility with legacy webmaps
        // when they have packaged areas but have incomplete metadata.
        // When the preplanned map area finishes loading, if its
        // packaging status is `nil`, we consider it as completed.
        await model.load()
        guard case .packaged = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaged\".")
            return
        }
        
        // In this case, the areas can be downloaded.
        XCTAssertTrue(model.canDownload)
        XCTAssertFalse(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testLoadFailureStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws {
                // Throws an error other than `MappingError.packagingNotComplete`
                // to indicate the area fails to load in the first place.
                throw MappingError.notLoaded(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        await model.load()
        
        guard case .loadFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".loadFailure\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertTrue(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testPackagingStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                packagingStatus = .processing
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        await model.load()
        
        guard case .packaging = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaging\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertFalse(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testPackagedStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                packagingStatus = .complete
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        await model.load()
        
        guard case .packaged = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaged\".")
            return
        }
        
        XCTAssertTrue(model.canDownload)
        XCTAssertFalse(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testPackageFailureStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                // The webmap metadata indicates the area fails to package.
                packagingStatus = .failed
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        await model.load()
        
        guard case .packageFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".packageFailure\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertTrue(model.status.needsToBeLoaded)
    }
    
    @MainActor
    func testPackagingNotCompletePackageFailureStatus() async throws {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                // Throws an error to indicate the area loaded successfully,
                // but is still packaging.
                throw MappingError.packagingNotComplete(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(preplannedMapArea: mockArea)
        await model.load()
        
        guard case .packageFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".loadFailure\".")
            return
        }
        
        XCTAssertFalse(model.canDownload)
        XCTAssertTrue(model.status.needsToBeLoaded)
    }
}
