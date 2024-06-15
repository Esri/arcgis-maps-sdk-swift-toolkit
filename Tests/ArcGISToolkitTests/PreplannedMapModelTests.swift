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
import Combine
@testable import ArcGISToolkit

private extension PreplannedMapAreaProtocol {
    var mapArea: PreplannedMapArea? { nil }
    var id: PortalItem.ID? { PortalItem.ID("012345") }
    var packagingStatus: PreplannedMapArea.PackagingStatus? { nil }
    var title: String { "Mock Preplanned Map Area" }
    var description: String { "This is the description text" }
    var thumbnail: LoadableImage? { nil }
    
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        throw NSError()
    }
}

class PreplannedMapModelTests: XCTestCase {
    private static var sleepNanoseconds: UInt64 { 1_000_000 }
    
    @MainActor
    func testInit() {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        XCTAssertIdentical(model.preplannedMapArea as? MockPreplannedMapArea, mockArea)
    }
    
    @MainActor
    func testInitialStatus() {
        class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        guard case .notLoaded = model.status else {
            XCTFail("PreplannedMapModel initial status is not \".notLoaded\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        Task { await model.load() }
        try await Task.sleep(nanoseconds: PreplannedMapModelTests.sleepNanoseconds)
        guard case .loading = model.status else {
            XCTFail("PreplannedMapModel status is not \".loading\".")
            return
        }
    }
    
    @MainActor
    func testNilPackagingStatus() async throws {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        
        // Packaging status is `nil` for compatibility with legacy webmaps
        // when they have packaged areas but have incomplete metadata.
        // When the preplanned map area finishes loading, if its
        // packaging status is `nil`, we consider it as completed.
        await model.load()
        guard case .packaged = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaged\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        await model.load()
        
        guard case .loadFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".loadFailure\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        await model.load()
        
        guard case .packaging = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaging\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        await model.load()
        
        guard case .packaged = model.status else {
            XCTFail("PreplannedMapModel status is not \".packaged\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        await model.load()
        
        guard case .packageFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".packageFailure\".")
            return
        }
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
        let model = PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mockArea,
            portalItemID: "",
            preplannedMapAreaID: ""
        )
        await model.load()
        
        guard case .packageFailure = model.status else {
            XCTFail("PreplannedMapModel status is not \".loadFailure\".")
            return
        }
    }
    
    @MainActor
    func testDownloadStatuses() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.id)
        
        defer {
            // Clean up
            let directory = FileManager.default.mmpkDirectory(forPortalItemID: portalItem.id!.rawValue, preplannedMapAreaID: areaID.rawValue)
            try? FileManager.default.removeItem(at: directory)
        }
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: "acc027394bc84c2fb04d1ed317aac674",
            preplannedMapAreaID: areaID.rawValue
        )
        
        var statuses = [PreplannedMapModel.Status]()
        var subscriptions = Set<AnyCancellable>()
        model.$status
            .receive(on: DispatchQueue.main)
            .sink { value in
                statuses.append(value)
            }
            .store(in: &subscriptions)
        
        await model.load()
        
        // Start downloading
        await model.downloadPreplannedMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Give the final status some time to be updated.
        try? await Task.sleep(nanoseconds: 1_000_000)
        
        // Verify statuses
        let expectedStatusCount = 6
        guard statuses.count == expectedStatusCount else {
            XCTFail("Expected a statuses count of \(expectedStatusCount), count is \(statuses.count).")
            return
        }
        
        let expected: [PreplannedMapModel.Status] = [
            .notLoaded,
            .loading,
            .packaged,
            .downloading,
            .downloading,
            .downloaded
        ]
        
        for zipped in zip(statuses, expected) {
            let status = zipped.0
            let expected = zipped.1
            if !status.matches(other: expected) {
                XCTFail("Status \(status) was expected to be \"\(expected)\".")
            }
        }
    }
}

private extension PreplannedMapModel.Status {
    /// Checks if another value is equivalent to this value ignoring
    /// any associated values.
    func matches(other: Self) -> Bool {
        switch self {
        case .notLoaded:
            if case .notLoaded = other { true } else { false }
        case .loading:
            if case .loading = other { true } else { false }
        case .loadFailure:
            if case .loadFailure = other { true } else { false }
        case .packaged:
            if case .packaged = other { true } else { false }
        case .packaging:
            if case .packaging = other { true } else { false }
        case .packageFailure:
            if case .packageFailure = other { true } else { false }
        case .downloading:
            if case .downloading = other { true } else { false }
        case .downloaded:
            if case .downloaded = other { true } else { false }
        case .downloadFailure:
            if case .downloadFailure = other { true } else { false }
        }
    }
}
