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
    var packagingStatus: PreplannedMapArea.PackagingStatus? { nil }
    var title: String { "Mock Preplanned Map Area" }
    var description: String { "This is the description text" }
    var thumbnail: LoadableImage? { nil }
    
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        throw NSError()
    }
}

class PreplannedMapModelTests: XCTestCase {
    @MainActor
    func testInit() {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        XCTAssertIdentical(model.preplannedMapArea as? MockPreplannedMapArea, mockArea)
    }
    
    @MainActor
    func testInitialStatus() {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        model.status.assertExpectedValue(.notLoaded)
    }
    
    @MainActor
    func testNilPackagingStatus() async throws {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws { }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        
        // Packaging status is `nil` for compatibility with legacy webmaps
        // when they have packaged areas but have incomplete metadata.
        // When the preplanned map area finishes loading, if its
        // packaging status is `nil`, we consider it as completed.
        await model.load()
        model.status.assertExpectedValue(.packaged)
    }
    
    @MainActor
    func testLoadFailureStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws {
                // Throws an error other than `MappingError.packagingNotComplete`
                // to indicate the area fails to load in the first place.
                throw MappingError.notLoaded(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        model.status.assertExpectedValue(.loadFailure(MappingError.notLoaded(details: "")))
    }
    
    @MainActor
    func testPackagingStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol, @unchecked Sendable {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                packagingStatus = .processing
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        model.status.assertExpectedValue(.packaging)
    }
    
    @MainActor
    func testPackagedStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol, @unchecked Sendable {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                packagingStatus = .complete
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        model.status.assertExpectedValue(.packaged)
    }
    
    @MainActor
    func testPackageFailureStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol, @unchecked Sendable {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                // The webmap metadata indicates the area fails to package.
                packagingStatus = .failed
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        model.status.assertExpectedValue(.packageFailure)
    }
    
    @MainActor
    func testPackagingNotCompletePackageFailureStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol, @unchecked Sendable {
            var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
            
            func retryLoad() async throws {
                // Throws an error to indicate the area loaded successfully,
                // but is still packaging.
                throw MappingError.packagingNotComplete(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        model.status.assertExpectedValue(.packageFailure)
    }
    
    /// This tests that the initial status is "downloading" if there is a matching job
    /// in the job manager.
    @MainActor
    func testStartupDownloadingStatus() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        let mmpkDirectory = FileManager.default.preplannedDirectory(
            forPortalItemID: portalItem.id!,
            preplannedMapAreaID: areaID
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
        // Add a job to the job manager so that when creating the model it finds it.
        let parameters = try await task.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: area)
        let job = task.makeDownloadPreplannedOfflineMapJob(parameters: parameters, downloadDirectory: mmpkDirectory)
        OfflineManager.shared.jobManager.jobs.append(job)
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItem.id!,
            preplannedMapAreaID: areaID,
            // User notifications in unit tests are not supported, must pass false here
            // or the test process will crash.
            showsUserNotificationOnCompletion: false
        )
        
        model.status.assertExpectedValue(.downloading)
        
        // Cancel the job to be a good citizen.
        await job.cancel()
    }
    
    @MainActor
    func testDownloadStatuses() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            let directory = FileManager.default.preplannedDirectory(
                forPortalItemID: portalItem.id!,
                preplannedMapAreaID: areaID
            )
            try? FileManager.default.removeItem(at: directory)
        }
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItem.id!,
            preplannedMapAreaID: areaID,
            // User notifications in unit tests are not supported, must pass false here
            // or the test process will crash.
            showsUserNotificationOnCompletion: false
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
        
        for (status, expected) in zip(statuses, expected) {
            status.assertExpectedValue(expected)
        }
        
        // Now test that creating a new matching model will have the status set to
        // downloaded as there is a mmpk downloaded at the appropriate location.
        let model2 = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItem.id!,
            preplannedMapAreaID: areaID
        )
        
        model2.status.assertExpectedValue(.downloaded)
    }
}

private extension PreplannedMapModel.Status {
    /// Checks if another value is equivalent to this value ignoring
    /// any associated values.
    private func isMatch(for other: Self) -> Bool {
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
    
    func assertExpectedValue(_ expected: Self, file: StaticString = #filePath, line: UInt = #line) {
        guard !isMatch(for: expected) else { return }
        XCTFail("Status '\(self)' does not match expected status of '\(expected)'", file: file, line: line)
    }
}

private extension PreplannedMapModel {
    static func makeTest(mapArea: PreplannedMapAreaProtocol) -> PreplannedMapModel {
        PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mapArea,
            portalItemID: .init("test-item-id")!,
            preplannedMapAreaID: .init("test-preplanned-map-area-id")!
        )
    }
}
