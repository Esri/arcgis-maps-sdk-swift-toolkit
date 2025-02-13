// Copyright 2025 Esri
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

class OnDemandMapModelTests: XCTestCase {
    /// Tests creating a model with a configuration for taking an area offline.
    @MainActor
    func testInitWithConfiguration() {
        let configuration = OnDemandMapModel.configuration
        let model = OnDemandMapModel(
            offlineMapTask: OfflineMapTask(onlineMap: Map()),
            configuration: configuration,
            portalItemID: .init("test-item-id")!,
            onRemoveDownload: { _ in }
        )
        XCTAssertEqual(model.title, "Mock On Demand Map Area")
        XCTAssertNotNil(model.areaID)
        XCTAssertEqual(model.areaID, configuration.areaID)
        XCTAssertNotNil(model.thumbnail)
        XCTAssertNil(model.mobileMapPackage)
        XCTAssertNil(model.job)
        XCTAssertEqual(model.directorySize, 0)
        XCTAssertEqual(model.status, .initialized)
    }
    
    /// Tests creating a model for a job that is already running.
    @MainActor
    func testInitWithJob() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let areaID = OnDemandMapModel.makeAreaID()
        let mmpkDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
        let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
        
        OfflineManager.shared.jobManager.jobs.append(job)
        
        let model = OnDemandMapModel(
            job: job,
            areaID: areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        XCTAssertFalse(model.title.isEmpty)
        XCTAssertNotNil(model.areaID)
        XCTAssertEqual(model.areaID, areaID)
        XCTAssertNil(model.thumbnail)
        XCTAssertNil(model.mobileMapPackage)
        XCTAssertNotNil(model.job)
        XCTAssertEqual(model.directorySize, 0)
        XCTAssertEqual(model.status, .downloading)
    }
    
    /// Tests creating a model for a map area that has already been downloaded.
    @MainActor
    func testInitWithAreaID() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let configuration = OnDemandMapModel.configuration
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        XCTAssertEqual(model.title, "Mock On Demand Map Area")
        XCTAssertNotNil(model.areaID)
        XCTAssertEqual(model.areaID, configuration.areaID)
        XCTAssertEqual(model.status, .initialized)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            model.removeDownloadedArea()
        }
        
        // Start downloading.
        await model.downloadOnDemandMapArea()
        
        XCTAssertEqual(model.status, .downloading)
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        XCTAssertEqual(model.status, .downloaded)
        
        let model2 = await OnDemandMapModel(
            areaID: model.areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        let downloadedModel = try XCTUnwrap(model2)
        XCTAssertEqual(downloadedModel.title, "Mock On Demand Map Area")
        XCTAssertNotNil(downloadedModel.areaID)
        XCTAssertNotNil(model.thumbnail)
        XCTAssertNotNil(model.mobileMapPackage)
        XCTAssertNil(model.job)
        XCTAssertGreaterThan(model.directorySize, 0)
        XCTAssertEqual(downloadedModel.status, .downloaded)
    }
    
    /// This tests that the initial status is "downloading" if there is a matching job
    /// in the job manager.
    @MainActor
    func testStartupDownloadingStatus() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let areaID = OnDemandAreaID()
        let mmpkDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
        let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
        
        OfflineManager.shared.jobManager.jobs.append(job)
        
        let model = OnDemandMapModel(
            job: job,
            areaID: areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        
        XCTAssertEqual(model.status, .downloading)
        
        // Cancel the job to be a good citizen.
        await job.cancel()
    }
    
    @MainActor
    func testDownloadStatuses() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let configuration = OnDemandMapModel.configuration
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            model.removeDownloadedArea()
        }
        
        var statuses = [OnDemandMapModel.Status]()
        var subscriptions = Set<AnyCancellable>()
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { value in
                statuses.append(value)
            }
            .store(in: &subscriptions)
        
        // Start downloading.
        await model.downloadOnDemandMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.initialized, .downloading, .downloaded]
        )
        
        // Now test that creating a new matching model will have the status set to
        // downloaded as there is an mmpk downloaded at the appropriate location.
        let model2 = await OnDemandMapModel(
            areaID: model.areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        let downloadedModel = try XCTUnwrap(model2)
        XCTAssertEqual(downloadedModel.status, .downloaded)
    }
    
    @MainActor
    func testLoadMobileMapPackage() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let configuration = OnDemandMapModel.configuration
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            model.removeDownloadedArea()
        }
        
        var statuses: [OnDemandMapModel.Status] = []
        var subscriptions: Set<AnyCancellable> = []
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { statuses.append($0) }
            .store(in: &subscriptions)
        
        // Start downloading.
        await model.downloadOnDemandMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.initialized, .downloading, .downloaded]
        )
        
        // Verify that mobile map package can be loaded.
        XCTAssertNotNil(model.map)
    }
    
    @MainActor
    func testRemoveDownloadedMapArea() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let offlineMapTask = OfflineMapTask(portalItem: portalItem)
        let configuration = OnDemandMapModel.configuration
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
        }
        
        var statuses = [OnDemandMapModel.Status]()
        var subscriptions = Set<AnyCancellable>()
        model.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { value in
                statuses.append(value)
            }
            .store(in: &subscriptions)
        
        // Start downloading.
        await model.downloadOnDemandMapArea()
        
        // Wait for job to finish.
        _ = await model.job?.result
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloaded
        }
        XCTAssertEqual(
            statuses,
            [.initialized, .downloading, .downloaded]
        )
        
        // Clean up folder.
        model.removeDownloadedArea()
        
        // Verify statuses after remove.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .initialized
        }
        XCTAssertEqual(
            statuses,
            [.initialized, .downloading, .downloaded, .initialized]
        )
    }
}

extension OnDemandMapModel.Status: Equatable {
    public static func == (lhs: OnDemandMapModel.Status, rhs: OnDemandMapModel.Status) -> Bool {
        return switch (lhs, rhs) {
        case (.initialized, .initialized),
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

private extension OnDemandMapModel {
    static var configuration: OnDemandMapAreaConfiguration {
        let envelope = Envelope(
            xRange: -13847794.834275939 ... -13396855.565869562,
            yRange: 3894735.5338846594...4345674.802291036,
            spatialReference: SpatialReference(wkid: WKID(3857)!, verticalWKID: nil)
        )
        
        return OnDemandMapAreaConfiguration(
            title: "Mock On Demand Map Area",
            minScale: 0,
            maxScale: 9027.977411,
            areaOfInterest: envelope,
            thumbnail: UIImage(systemName: "map")
        )
    }
    
    static func makeAreaID() -> OnDemandAreaID {
        OnDemandAreaID()
    }
    
    static func makeJob(for mmpkDirectory: URL, task: OfflineMapTask) async throws -> GenerateOfflineMapJob {
        let parameters = try await task.makeDefaultGenerateOfflineMapParameters(
            areaOfInterest: configuration.areaOfInterest,
            minScale: configuration.minScale,
            maxScale: configuration.maxScale
        )
        
        return task.makeGenerateOfflineMapJob(
            parameters: parameters,
            downloadDirectory: mmpkDirectory
        )
    }
}
