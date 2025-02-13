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
import Combine
@testable ***REMOVED***Toolkit

class OnDemandMapModelTests: XCTestCase {
***REMOVED******REMOVED***/ Tests creating a model with a configuration for taking an area offline.
***REMOVED***@MainActor
***REMOVED***func testInitWithConfiguration() {
***REMOVED******REMOVED***let configuration = OnDemandMapModel.configuration
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: .init("test-item-id")!,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertEqual(model.title, "Mock On Demand Map Area")
***REMOVED******REMOVED***XCTAssertNotNil(model.areaID)
***REMOVED******REMOVED***XCTAssertEqual(model.areaID, configuration.areaID)
***REMOVED******REMOVED***XCTAssertNotNil(model.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(model.mobileMapPackage)
***REMOVED******REMOVED***XCTAssertNil(model.job)
***REMOVED******REMOVED***XCTAssertEqual(model.directorySize, 0)
***REMOVED******REMOVED***XCTAssertEqual(model.status, .initialized)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Tests creating a model for a job that is already running.
***REMOVED***@MainActor
***REMOVED***func testInitWithJob() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areaID = OnDemandMapModel.makeAreaID()
***REMOVED******REMOVED***let mmpkDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectory)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
***REMOVED******REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.append(job)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***job: job,
***REMOVED******REMOVED******REMOVED***areaID: areaID,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertFalse(model.title.isEmpty)
***REMOVED******REMOVED***XCTAssertNotNil(model.areaID)
***REMOVED******REMOVED***XCTAssertEqual(model.areaID, areaID)
***REMOVED******REMOVED***XCTAssertNil(model.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(model.mobileMapPackage)
***REMOVED******REMOVED***XCTAssertNotNil(model.job)
***REMOVED******REMOVED***XCTAssertEqual(model.directorySize, 0)
***REMOVED******REMOVED***XCTAssertEqual(model.status, .downloading)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Tests creating a model for a map area that has already been downloaded.
***REMOVED***@MainActor
***REMOVED***func testInitWithAreaID() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let configuration = OnDemandMapModel.configuration
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertEqual(model.title, "Mock On Demand Map Area")
***REMOVED******REMOVED***XCTAssertNotNil(model.areaID)
***REMOVED******REMOVED***XCTAssertEqual(model.areaID, configuration.areaID)
***REMOVED******REMOVED***XCTAssertEqual(model.status, .initialized)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(model.status, .downloading)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(model.status, .downloaded)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model2 = await OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***areaID: model.areaID,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let downloadedModel = try XCTUnwrap(model2)
***REMOVED******REMOVED***XCTAssertEqual(downloadedModel.title, "Mock On Demand Map Area")
***REMOVED******REMOVED***XCTAssertNotNil(downloadedModel.areaID)
***REMOVED******REMOVED***XCTAssertNotNil(model.thumbnail)
***REMOVED******REMOVED***XCTAssertNotNil(model.mobileMapPackage)
***REMOVED******REMOVED***XCTAssertNil(model.job)
***REMOVED******REMOVED***XCTAssertGreaterThan(model.directorySize, 0)
***REMOVED******REMOVED***XCTAssertEqual(downloadedModel.status, .downloaded)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ This tests that the initial status is "downloading" if there is a matching job
***REMOVED******REMOVED***/ in the job manager.
***REMOVED***@MainActor
***REMOVED***func testStartupDownloadingStatus() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areaID = OnDemandAreaID()
***REMOVED******REMOVED***let mmpkDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectory)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let job = try await OnDemandMapModel.makeJob(for: mmpkDirectory, task: offlineMapTask)
***REMOVED******REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.append(job)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***job: job,
***REMOVED******REMOVED******REMOVED***areaID: areaID,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(model.status, .downloading)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Cancel the job to be a good citizen.
***REMOVED******REMOVED***await job.cancel()
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testDownloadStatuses() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let configuration = OnDemandMapModel.configuration
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses = [OnDemandMapModel.Status]()
***REMOVED******REMOVED***var subscriptions = Set<AnyCancellable>()
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.removeDuplicates()
***REMOVED******REMOVED******REMOVED***.sink { value in
***REMOVED******REMOVED******REMOVED******REMOVED***statuses.append(value)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED******REMOVED*** First give time for final status to come in.
***REMOVED******REMOVED***try? await Task.yield(timeout: 0.1) { @MainActor in
***REMOVED******REMOVED******REMOVED***statuses.last == .downloaded
***REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.initialized, .downloading, .downloaded]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Now test that creating a new matching model will have the status set to
***REMOVED******REMOVED******REMOVED*** downloaded as there is an mmpk downloaded at the appropriate location.
***REMOVED******REMOVED***let model2 = await OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***areaID: model.areaID,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let downloadedModel = try XCTUnwrap(model2)
***REMOVED******REMOVED***XCTAssertEqual(downloadedModel.status, .downloaded)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadMobileMapPackage() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let configuration = OnDemandMapModel.configuration
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses: [OnDemandMapModel.Status] = []
***REMOVED******REMOVED***var subscriptions: Set<AnyCancellable> = []
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.removeDuplicates()
***REMOVED******REMOVED******REMOVED***.sink { statuses.append($0) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED******REMOVED*** First give time for final status to come in.
***REMOVED******REMOVED***try? await Task.yield(timeout: 0.1) { @MainActor in
***REMOVED******REMOVED******REMOVED***statuses.last == .downloaded
***REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.initialized, .downloading, .downloaded]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that mobile map package can be loaded.
***REMOVED******REMOVED***XCTAssertNotNil(model.map)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testRemoveDownloadedMapArea() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("3da658f2492f4cfd8494970ef489d2c5")!)
***REMOVED******REMOVED***let portalItemID = try XCTUnwrap(portalItem.id)
***REMOVED******REMOVED***let offlineMapTask = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let configuration = OnDemandMapModel.configuration
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED***configuration: configuration,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: { _ in ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses = [OnDemandMapModel.Status]()
***REMOVED******REMOVED***var subscriptions = Set<AnyCancellable>()
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.removeDuplicates()
***REMOVED******REMOVED******REMOVED***.sink { value in
***REMOVED******REMOVED******REMOVED******REMOVED***statuses.append(value)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED******REMOVED*** First give time for final status to come in.
***REMOVED******REMOVED***try? await Task.yield(timeout: 0.1) { @MainActor in
***REMOVED******REMOVED******REMOVED***statuses.last == .downloaded
***REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.initialized, .downloading, .downloaded]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses after remove.
***REMOVED******REMOVED******REMOVED*** First give time for final status to come in.
***REMOVED******REMOVED***try? await Task.yield(timeout: 0.1) { @MainActor in
***REMOVED******REMOVED******REMOVED***statuses.last == .initialized
***REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.initialized, .downloading, .downloaded, .initialized]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension OnDemandMapModel.Status: Equatable {
***REMOVED***public static func == (lhs: OnDemandMapModel.Status, rhs: OnDemandMapModel.Status) -> Bool {
***REMOVED******REMOVED***return switch (lhs, rhs) {
***REMOVED******REMOVED***case (.initialized, .initialized),
***REMOVED******REMOVED******REMOVED***(.downloading, .downloading),
***REMOVED******REMOVED******REMOVED***(.downloaded, .downloaded),
***REMOVED******REMOVED******REMOVED***(.downloadFailure, .downloadFailure),
***REMOVED******REMOVED******REMOVED***(.mmpkLoadFailure, .mmpkLoadFailure):
***REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***false
***REMOVED***
***REMOVED***
***REMOVED***

private extension OnDemandMapModel {
***REMOVED***static var configuration: OnDemandMapAreaConfiguration {
***REMOVED******REMOVED***let envelope = Envelope(
***REMOVED******REMOVED******REMOVED***xRange: -13847794.834275939 ... -13396855.565869562,
***REMOVED******REMOVED******REMOVED***yRange: 3894735.5338846594...4345674.802291036,
***REMOVED******REMOVED******REMOVED***spatialReference: SpatialReference(wkid: WKID(3857)!, verticalWKID: nil)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return OnDemandMapAreaConfiguration(
***REMOVED******REMOVED******REMOVED***title: "Mock On Demand Map Area",
***REMOVED******REMOVED******REMOVED***minScale: 0,
***REMOVED******REMOVED******REMOVED***maxScale: 9027.977411,
***REMOVED******REMOVED******REMOVED***areaOfInterest: envelope,
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(systemName: "map")
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static func makeAreaID() -> OnDemandAreaID {
***REMOVED******REMOVED***OnDemandAreaID()
***REMOVED***
***REMOVED***
***REMOVED***static func makeJob(for mmpkDirectory: URL, task: OfflineMapTask) async throws -> GenerateOfflineMapJob {
***REMOVED******REMOVED***let parameters = try await task.makeDefaultGenerateOfflineMapParameters(
***REMOVED******REMOVED******REMOVED***areaOfInterest: configuration.areaOfInterest,
***REMOVED******REMOVED******REMOVED***minScale: configuration.minScale,
***REMOVED******REMOVED******REMOVED***maxScale: configuration.maxScale
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return task.makeGenerateOfflineMapJob(
***REMOVED******REMOVED******REMOVED***parameters: parameters,
***REMOVED******REMOVED******REMOVED***downloadDirectory: mmpkDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
