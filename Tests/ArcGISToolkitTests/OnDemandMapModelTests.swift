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
    override func setUp() async throws {
        ArcGISEnvironment.apiKey = .default
    }
    
    override func tearDown() {
        ArcGISEnvironment.apiKey = nil
    }
    
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
        
        let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
        
        OfflineManager.shared.jobManager.jobs.append(job)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
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
        
        // Cancel the job to be a good citizen.
        await job.cancel()
    }
    
    /// Tests creating a model for a map area that has already been downloaded.
    @MainActor
    func testInitWithAreaID() async throws {
        let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
        let portalItemID = try XCTUnwrap(portalItem.id)
        let areaID = OnDemandMapModel.makeAreaID()
        
        // Verify that model initialization fails when mmpk directory is empty.
        let model = await OnDemandMapModel(
            areaID: areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        XCTAssertNil(model)
        
        // Create mmpk directory and verify it exists before creating model.
        let directory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
        let mmpkDirectory = OnDemandMapModel.mmpkDirectory(forOnDemandDirectory: directory)
        try FileManager.default.createDirectory(at: mmpkDirectory, withIntermediateDirectories: true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: mmpkDirectory.path()))
        
        defer {
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
        // Verify that model initialization succeeds when mmpk directory is not empty.
        let model2 = await OnDemandMapModel(
            areaID: areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        XCTAssertNotNil(model2)
        let downloadedModel = try XCTUnwrap(model2)
        XCTAssertNotNil(downloadedModel.areaID)
        XCTAssertNil(downloadedModel.job)
        XCTAssertFalse(downloadedModel.isDownloaded)
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
        
        let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
        
        OfflineManager.shared.jobManager.jobs.append(job)
        
        defer {
            // Clean up JobManager.
            OfflineManager.shared.jobManager.jobs.removeAll()
            
            // Clean up folder.
            try? FileManager.default.removeItem(at: mmpkDirectory)
        }
        
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
    
    /// Tests that the model status changes from `initialized` to `downloading` when the download starts.
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
            
            // Cancel downolad job.
            model.cancelJob()
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
        
        // Verify statuses.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .downloading
        }
        XCTAssertEqual(
            statuses,
            [.initialized, .downloading]
        )
    }
    
    @MainActor
    func testLoadMobileMapPackage() async throws {
        ArcGISEnvironment.backgroundURLSession = .init(configurationProvider: { .default })
        
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
            
            // Cancel downolad job.
            model.cancelJob()
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
        let areaID = OnDemandMapModel.makeAreaID()
        
        // Create mmpk directory and verify it exists before creating model.
        let directory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
        let mmpkDirectory = OnDemandMapModel.mmpkDirectory(forOnDemandDirectory: directory)
        try FileManager.default.createDirectory(at: mmpkDirectory, withIntermediateDirectories: true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: mmpkDirectory.path()))
        
        let model = await OnDemandMapModel(
            areaID: areaID,
            portalItemID: portalItemID,
            onRemoveDownload: { _ in }
        )
        let downloadedModel = try XCTUnwrap(model)
        
        var statuses = [OnDemandMapModel.Status]()
        var subscriptions = Set<AnyCancellable>()
        downloadedModel.$status
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { value in
                statuses.append(value)
            }
            .store(in: &subscriptions)
        
        XCTAssertNotEqual(downloadedModel.status, .initialized)
        
        // Clean up folder.
        downloadedModel.removeDownloadedArea()
        
        // Verify statuses after remove.
        // First give time for final status to come in.
        try? await Task.yield(timeout: 0.1) { @MainActor in
            statuses.last == .initialized
        }
        XCTAssertEqual(statuses.last, .initialized)
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
        let envelope = Envelope(center: .init(x: 0, y: 0, spatialReference: .webMercator), width: 1, height: 1)
        
        return OnDemandMapAreaConfiguration(
            title: "Mock On Demand Map Area",
            minScale: 0,
            maxScale: 100_000_000,
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
