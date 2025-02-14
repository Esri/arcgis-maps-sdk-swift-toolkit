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
import os
@testable import ArcGISToolkit

private extension PreplannedMapAreaProtocol {
    var mapArea: PreplannedMapArea? { nil }
    var packagingStatus: PreplannedMapArea.PackagingStatus? { nil }
    var title: String { "Mock Preplanned Map Area" }
    var description: String { "This is the description text" }
    var thumbnail: LoadableImage? { nil }
    
    func retryLoad() async throws { }
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        throw CancellationError()
    }
}

class PreplannedMapModelTests: XCTestCase {
    override func setUp() async throws {
        ArcGISEnvironment.apiKey = .default
    }
    
    override func tearDown() {
        ArcGISEnvironment.apiKey = nil
    }
    
    @MainActor
    func testInit() {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {}
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        XCTAssert(model.preplannedMapArea is MockPreplannedMapArea)
    }
    
    @MainActor
    func testInitialStatus() {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {}
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        XCTAssertEqual(model.status, .notLoaded)
    }
    
    @MainActor
    func testNilPackagingStatus() async throws {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {}
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        
        // Packaging status is `nil` for compatibility with legacy webmaps
        // when they have packaged areas but have incomplete metadata.
        // When the preplanned map area finishes loading, if its
        // packaging status is `nil`, we consider it as completed.
        await model.load()
        XCTAssertEqual(model.status, .packaged)
    }
    
    @MainActor
    func testLoadFailureStatus() async throws {
        struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
            func retryLoad() async throws {
                // Throws an error other than `MappingError.packagingNotComplete`
                // to indicate the area fails to load in the first place.
                throw MappingError.notLoaded(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        XCTAssertEqual(model.status, .loadFailure(MappingError.notLoaded(details: "")))
    }
    
    @MainActor
    func testPackagingStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? {
                _packagingStatus.withLock { $0 }
            }
            
            private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
            
            func retryLoad() async throws {
                _packagingStatus.withLock { $0 = .processing }
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        XCTAssertEqual(model.status, .packaging)
    }
    
    @MainActor
    func testPackagedStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? {
                _packagingStatus.withLock { $0 }
            }
            
            private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
            
            func retryLoad() async throws {
                _packagingStatus.withLock { $0 = .complete }
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        XCTAssertEqual(model.status, .packaged)
    }
    
    @MainActor
    func testPackageFailureStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? {
                _packagingStatus.withLock { $0 }
            }
            
            private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
            
            func retryLoad() async throws {
                // The webmap metadata indicates the area fails to package.
                _packagingStatus.withLock { $0 = .failed }
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        XCTAssertEqual(model.status, .packageFailure)
    }
    
    @MainActor
    func testPackagingNotCompletePackageFailureStatus() async throws {
        final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
            var packagingStatus: PreplannedMapArea.PackagingStatus? { nil }
            
            func retryLoad() async throws {
                // Throws an error to indicate the area loaded successfully,
                // but is still packaging.
                throw MappingError.packagingNotComplete(details: "")
            }
        }
        
        let mockArea = MockPreplannedMapArea()
        let model = PreplannedMapModel.makeTest(mapArea: mockArea)
        await model.load()
        XCTAssertEqual(model.status, .packageFailure)
    }
    
    /// This tests that the initial status is "downloading" if there is a matching job
    /// in the job manager.
    @MainActor
    func testStartupDownloadingStatus() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        let mmpkDirectory = URL.documentsDirectory
            .appending(
                components: "OfflineMapAreas",
                "\(portalItemID)",
                "Preplanned",
                "\(areaID)",
                directoryHint: .isDirectory
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
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        await model.load()
        XCTAssertEqual(model.status, .downloading)
        
        // Cancel the job to be a good citizen.
        await job.cancel()
    }
    
    @MainActor
    func testDownloadStatuses() async throws {
        ArcGISEnvironment.backgroundURLSession = .init(configurationProvider: { .default })
        
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            model.removeDownloadedArea()
        }
        
        var statuses = [PreplannedMapModel.Status]()
        var subscriptions = Set<AnyCancellable>()
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { value in
                statuses.append(value)
            }
            .store(in: &subscriptions)
        
        await model.load()
        
        // Start downloading.
        await model.downloadPreplannedMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.notLoaded, .loading, .packaged, .downloading, .downloaded]
        )
        
        // Now test that creating a new matching model will have the status set to
        // downloaded as there is an mmpk downloaded at the appropriate location.
        let model2 = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        await model2.load()
        XCTAssertEqual(model2.status, .downloaded)
    }
    
    @MainActor
    func testLoadMobileMapPackage() async throws {
        ArcGISEnvironment.backgroundURLSession = .init(configurationProvider: { .default })
        
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            model.removeDownloadedArea()
        }
        
        var statuses: [PreplannedMapModel.Status] = []
        var subscriptions: Set<AnyCancellable> = []
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { statuses.append($0) }
            .store(in: &subscriptions)
        
        await model.load()
        
        // Start downloading.
        await model.downloadPreplannedMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.notLoaded, .loading, .packaged, .downloading, .downloaded]
        )
        
        // Verify that mobile map package can be loaded.
        XCTAssertNotNil(model.map)
    }
    
    @MainActor
    func testRemoveDownloadedPreplannedMapArea() async throws {
        ArcGISEnvironment.backgroundURLSession = .init(configurationProvider: { .default })
        
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: .init("acc027394bc84c2fb04d1ed317aac674")!
        )
        let portalItemID = try XCTUnwrap(portalItem.id)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first)
        let areaID = try XCTUnwrap(area.portalItem.id)
        
        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        
        var statuses: [PreplannedMapModel.Status] = []
        var subscriptions = Set<AnyCancellable>()
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { statuses.append($0) }
            .store(in: &subscriptions)
        
        await model.load()
        
        // Start downloading.
        await model.downloadPreplannedMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses after download.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.notLoaded, .loading, .packaged, .downloading, .downloaded]
        )
        
        // Clean up folder.
        model.removeDownloadedArea()
        
        // Verify statuses after remove.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .packaged
        }
        XCTAssertEqual(
            statuses,
            [.notLoaded, .loading, .packaged, .downloading, .downloaded, .notLoaded, .loading, .packaged]
        )
    }
    
    @MainActor
    func testPreplannedMapModelDescription() async throws {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: .init("acc027394bc84c2fb04d1ed317aac674")!
        )
        let portalItemID = try XCTUnwrap(portalItem.id)
        let task = OfflineMapTask(portalItem: portalItem)
        let areas = try await task.preplannedMapAreas
        let area = try XCTUnwrap(areas.first { $0.title == "Country Commons Area" })
        let areaID = try XCTUnwrap(area.portalItem.id)

        let model = PreplannedMapModel(
            offlineMapTask: task,
            mapArea: area,
            portalItemID: portalItemID,
            preplannedMapAreaID: areaID,
            onRemoveDownload: {}
        )
        
        // Verify description does not contain HTML tags.
        XCTAssertEqual(
            model.preplannedMapArea.description,
            "A map that contains stormwater network within Naperville, IL, USA with cartography designed for web and mobile devices. This is a demo map to demonstrate offline capabilities with ArcGIS Runtime and is based on ArcGIS Solutions for Stormwater."
        )
    }
}

extension PreplannedMapModel.Status: Equatable {
    public static func == (lhs: PreplannedMapModel.Status, rhs: PreplannedMapModel.Status) -> Bool {
        return switch (lhs, rhs) {
        case (.notLoaded, .notLoaded),
            (.loading, .loading),
            (.loadFailure, .loadFailure),
            (.packaged, .packaged),
            (.packaging, .packaging),
            (.packageFailure, .packageFailure),
            (.downloading, .downloading),
            (.downloaded, .downloaded),
            (.downloadFailure, .downloadFailure),
            (.mmpkLoadFailure, .mmpkLoadFailure):
            true
        default:
            false
        }
    }
}

private extension PreplannedMapModel {
    static func makeTest(mapArea: PreplannedMapAreaProtocol) -> PreplannedMapModel {
        PreplannedMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            mapArea: mapArea,
            portalItemID: .init("test-item-id")!,
            preplannedMapAreaID: .init("test-preplanned-map-area-id")!,
            onRemoveDownload: {}
        )
    }
}
