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
import Combine
import os
@testable ***REMOVED***Toolkit

private extension PreplannedMapAreaProtocol {
***REMOVED***var mapArea: PreplannedMapArea? { nil ***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { nil ***REMOVED***
***REMOVED***var title: String { "Mock Preplanned Map Area" ***REMOVED***
***REMOVED***var description: String { "This is the description text" ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { nil ***REMOVED***
***REMOVED***
***REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***throw CancellationError()
***REMOVED***
***REMOVED***

class PreplannedMapModelTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***XCTAssert(model.preplannedMapArea is MockPreplannedMapArea)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testInitialStatus() {
***REMOVED******REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***XCTAssertEqual(model.status, .notLoaded)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testNilPackagingStatus() async throws {
***REMOVED******REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Packaging status is `nil` for compatibility with legacy webmaps
***REMOVED******REMOVED******REMOVED*** when they have packaged areas but have incomplete metadata.
***REMOVED******REMOVED******REMOVED*** When the preplanned map area finishes loading, if its
***REMOVED******REMOVED******REMOVED*** packaging status is `nil`, we consider it as completed.
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .packaged)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadFailureStatus() async throws {
***REMOVED******REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Throws an error other than `MappingError.packagingNotComplete`
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** to indicate the area fails to load in the first place.
***REMOVED******REMOVED******REMOVED******REMOVED***throw MappingError.notLoaded(details: "")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .loadFailure(MappingError.notLoaded(details: "")))
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagingStatus() async throws {
***REMOVED******REMOVED***final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? {
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 = .processing ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .packaging)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagedStatus() async throws {
***REMOVED******REMOVED***final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? {
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 = .complete ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .packaged)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackageFailureStatus() async throws {
***REMOVED******REMOVED***final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? {
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***private let _packagingStatus = OSAllocatedUnfairLock<PreplannedMapArea.PackagingStatus?>(initialState: nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The webmap metadata indicates the area fails to package.
***REMOVED******REMOVED******REMOVED******REMOVED***_packagingStatus.withLock { $0 = .failed ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .packageFailure)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagingNotCompletePackageFailureStatus() async throws {
***REMOVED******REMOVED***final class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Throws an error to indicate the area loaded successfully,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** but is still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED***throw MappingError.packagingNotComplete(details: "")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel.makeTest(mapArea: mockArea)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***XCTAssertEqual(model.status, .packageFailure)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ This tests that the initial status is "downloading" if there is a matching job
***REMOVED******REMOVED***/ in the job manager.
***REMOVED***@MainActor
***REMOVED***func testStartupDownloadingStatus() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.portalItem.id)
***REMOVED******REMOVED***let mmpkDirectory = URL.documentsDirectory
***REMOVED******REMOVED******REMOVED***.appending(
***REMOVED******REMOVED******REMOVED******REMOVED***components: "OfflineMapAreas",
***REMOVED******REMOVED******REMOVED******REMOVED***"\(portalItem.id!)",
***REMOVED******REMOVED******REMOVED******REMOVED***"Preplanned",
***REMOVED******REMOVED******REMOVED******REMOVED***"\(areaID)",
***REMOVED******REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectory)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add a job to the job manager so that when creating the model it finds it.
***REMOVED******REMOVED***let parameters = try await task.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: area)
***REMOVED******REMOVED***let job = task.makeDownloadPreplannedOfflineMapJob(parameters: parameters, downloadDirectory: mmpkDirectory)
***REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.append(job)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID,
***REMOVED******REMOVED******REMOVED******REMOVED*** User notifications in unit tests are not supported, must pass false here
***REMOVED******REMOVED******REMOVED******REMOVED*** or the test process will crash.
***REMOVED******REMOVED******REMOVED***showsUserNotificationOnCompletion: false
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
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.portalItem.id)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID,
***REMOVED******REMOVED******REMOVED******REMOVED*** User notifications in unit tests are not supported, must pass false here
***REMOVED******REMOVED******REMOVED******REMOVED*** or the test process will crash.
***REMOVED******REMOVED******REMOVED***showsUserNotificationOnCompletion: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***model.removeDownloadedPreplannedMapArea()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses = [PreplannedMapModel.Status]()
***REMOVED******REMOVED***var subscriptions = Set<AnyCancellable>()
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.sink { value in
***REMOVED******REMOVED******REMOVED******REMOVED***statuses.append(value)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give the final status some time to be updated.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 1_000_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.notLoaded, .loading, .packaged, .downloading, .downloading, .downloaded]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Now test that creating a new matching model will have the status set to
***REMOVED******REMOVED******REMOVED*** downloaded as there is a mmpk downloaded at the appropriate location.
***REMOVED******REMOVED***let model2 = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(model2.status, .downloaded)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadMobileMapPackage() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.portalItem.id)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID,
***REMOVED******REMOVED******REMOVED******REMOVED*** User notifications in unit tests are not supported, must pass false here
***REMOVED******REMOVED******REMOVED******REMOVED*** or the test process will crash.
***REMOVED******REMOVED******REMOVED***showsUserNotificationOnCompletion: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up JobManager.
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED******REMOVED***model.removeDownloadedPreplannedMapArea()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses: [PreplannedMapModel.Status] = []
***REMOVED******REMOVED***var subscriptions: Set<AnyCancellable> = []
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.sink { statuses.append($0) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that mobile map package can be loaded.
***REMOVED******REMOVED***let map = await model.map
***REMOVED******REMOVED***XCTAssertNotNil(map)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give the final status some time to be updated.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 1_000_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.notLoaded, .loading, .packaged, .downloading, .downloading, .downloaded]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testRemoveDownloadedPreplannedMapArea() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: .init("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.portalItem.id)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID,
***REMOVED******REMOVED******REMOVED******REMOVED*** User notifications in unit tests are not supported, must pass false here
***REMOVED******REMOVED******REMOVED******REMOVED*** or the test process will crash.
***REMOVED******REMOVED******REMOVED***showsUserNotificationOnCompletion: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var statuses: [PreplannedMapModel.Status] = []
***REMOVED******REMOVED***var subscriptions = Set<AnyCancellable>()
***REMOVED******REMOVED***model.$status
***REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.sink { statuses.append($0) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Start downloading.
***REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clean up folder.
***REMOVED******REMOVED***model.removeDownloadedPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give the final status some time to be updated.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 1_000_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***statuses,
***REMOVED******REMOVED******REMOVED***[.notLoaded, .loading, .packaged, .downloading, .downloading, .downloaded, .notLoaded, .loading, .packaged]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPreplannedMapModelDescription() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: .init("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first { $0.title == "Country Commons Area" ***REMOVED***)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.portalItem.id)

***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: portalItem.id!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID,
***REMOVED******REMOVED******REMOVED******REMOVED*** User notifications in unit tests are not supported, must pass false here
***REMOVED******REMOVED******REMOVED******REMOVED*** or the test process will crash.
***REMOVED******REMOVED******REMOVED***showsUserNotificationOnCompletion: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify description does not contain HTML tags.
***REMOVED******REMOVED***XCTAssertEqual(model.preplannedMapArea.description,
***REMOVED******REMOVED***"""
***REMOVED******REMOVED***A map that contains stormwater network within Naperville, IL, USA with cartography designed for web and mobile devices. This is a demo map to demonstrate offline capabilities with ArcGIS Runtime and is based on ArcGIS Solutions for Stormwater.
***REMOVED******REMOVED***""")
***REMOVED***
***REMOVED***

extension PreplannedMapModel.Status: Equatable {
***REMOVED***public static func == (lhs: PreplannedMapModel.Status, rhs: PreplannedMapModel.Status) -> Bool {
***REMOVED******REMOVED***return switch (lhs, rhs) {
***REMOVED******REMOVED***case (.notLoaded, .notLoaded),
***REMOVED******REMOVED******REMOVED***(.loading, .loading),
***REMOVED******REMOVED******REMOVED***(.loadFailure, .loadFailure),
***REMOVED******REMOVED******REMOVED***(.packaged, .packaged),
***REMOVED******REMOVED******REMOVED***(.packaging, .packaging),
***REMOVED******REMOVED******REMOVED***(.packageFailure, .packageFailure),
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

private extension PreplannedMapModel {
***REMOVED***static func makeTest(mapArea: PreplannedMapAreaProtocol) -> PreplannedMapModel {
***REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED***portalItemID: .init("test-item-id")!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: .init("test-preplanned-map-area-id")!
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
