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
@testable ***REMOVED***Toolkit

private extension PreplannedMapAreaProtocol {
***REMOVED***var mapArea: PreplannedMapArea? { nil ***REMOVED***
***REMOVED***var id: PortalItem.ID? { PortalItem.ID("012345") ***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { nil ***REMOVED***
***REMOVED***var title: String { "Mock Preplanned Map Area" ***REMOVED***
***REMOVED***var description: String { "This is the description text" ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { nil ***REMOVED***
***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***throw NSError()
***REMOVED***
***REMOVED***

class PreplannedMapModelTests: XCTestCase {
***REMOVED***private static var sleepNanoseconds: UInt64 { 1_000_000 ***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertIdentical(model.preplannedMapArea as? MockPreplannedMapArea, mockArea)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testInitialStatus() {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guard case .notLoaded = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel initial status is not \".notLoaded\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadingStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** In `retryLoad` method, simulate a time-consuming `load` method,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** so the model status stays at "loading".
***REMOVED******REMOVED******REMOVED******REMOVED***try await Task.sleep(nanoseconds: 2 * PreplannedMapModelTests.sleepNanoseconds)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***Task { await model.load() ***REMOVED***
***REMOVED******REMOVED***try await Task.sleep(nanoseconds: PreplannedMapModelTests.sleepNanoseconds)
***REMOVED******REMOVED***guard case .loading = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".loading\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testNilPackagingStatus() async throws {
***REMOVED******REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Packaging status is `nil` for compatibility with legacy webmaps
***REMOVED******REMOVED******REMOVED*** when they have packaged areas but have incomplete metadata.
***REMOVED******REMOVED******REMOVED*** When the preplanned map area finishes loading, if its
***REMOVED******REMOVED******REMOVED*** packaging status is `nil`, we consider it as completed.
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***guard case .packaged = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".packaged\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadFailureStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Throws an error other than `MappingError.packagingNotComplete`
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** to indicate the area fails to load in the first place.
***REMOVED******REMOVED******REMOVED******REMOVED***throw MappingError.notLoaded(details: "")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case .loadFailure = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".loadFailure\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagingStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED***packagingStatus = .processing
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case .packaging = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".packaging\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagedStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED***packagingStatus = .complete
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case .packaged = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".packaged\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackageFailureStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The webmap metadata indicates the area fails to package.
***REMOVED******REMOVED******REMOVED******REMOVED***packagingStatus = .failed
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case .packageFailure = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".packageFailure\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testPackagingNotCompletePackageFailureStatus() async throws {
***REMOVED******REMOVED***class MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func retryLoad() async throws {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Throws an error to indicate the area loaded successfully,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** but is still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED***throw MappingError.packagingNotComplete(details: "")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mockArea = MockPreplannedMapArea()
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: mockArea,
***REMOVED******REMOVED******REMOVED***portalItemID: "",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: ""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await model.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case .packageFailure = model.status else {
***REMOVED******REMOVED******REMOVED***XCTFail("PreplannedMapModel status is not \".loadFailure\".")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testDownloadStatuses() async throws {
***REMOVED******REMOVED***let portalItem = PortalItem(portal: Portal.arcGISOnline(connection: .anonymous), id: .init("acc027394bc84c2fb04d1ed317aac674")!)
***REMOVED******REMOVED***let task = OfflineMapTask(portalItem: portalItem)
***REMOVED******REMOVED***let areas = try await task.preplannedMapAreas
***REMOVED******REMOVED***let area = try XCTUnwrap(areas.first)
***REMOVED******REMOVED***let areaID = try XCTUnwrap(area.id)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Clean up
***REMOVED******REMOVED******REMOVED***let directory = FileManager.default.mmpkDirectory(forPortalItemID: portalItem.id!.rawValue, preplannedMapAreaID: areaID.rawValue)
***REMOVED******REMOVED******REMOVED***try? FileManager.default.removeItem(at: directory)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: task,
***REMOVED******REMOVED******REMOVED***mapArea: area,
***REMOVED******REMOVED******REMOVED***portalItemID: "acc027394bc84c2fb04d1ed317aac674",
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: areaID.rawValue
***REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED*** Start downloading
***REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED***_ = await model.job?.result
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give the final status some time to be updated.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 1_000_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify statuses
***REMOVED******REMOVED***let expectedStatusCount = 6
***REMOVED******REMOVED***guard statuses.count == expectedStatusCount else {
***REMOVED******REMOVED******REMOVED***XCTFail("Expected a statuses count of \(expectedStatusCount), count is \(statuses.count).")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let expected: [PreplannedMapModel.Status] = [
***REMOVED******REMOVED******REMOVED***.notLoaded,
***REMOVED******REMOVED******REMOVED***.loading,
***REMOVED******REMOVED******REMOVED***.packaged,
***REMOVED******REMOVED******REMOVED***.downloading,
***REMOVED******REMOVED******REMOVED***.downloading,
***REMOVED******REMOVED******REMOVED***.downloaded
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***for zipped in zip(statuses, expected) {
***REMOVED******REMOVED******REMOVED***let status = zipped.0
***REMOVED******REMOVED******REMOVED***let expected = zipped.1
***REMOVED******REMOVED******REMOVED***if !status.matches(other: expected) {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTFail("Status \(status) was expected to be \"\(expected)\".")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension PreplannedMapModel.Status {
***REMOVED******REMOVED***/ Checks if another value is equivalent to this value ignoring
***REMOVED******REMOVED***/ any associated values.
***REMOVED***func matches(other: Self) -> Bool {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED***if case .notLoaded = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED***if case .loading = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .loadFailure:
***REMOVED******REMOVED******REMOVED***if case .loadFailure = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .packaged:
***REMOVED******REMOVED******REMOVED***if case .packaged = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED***if case .packaging = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .packageFailure:
***REMOVED******REMOVED******REMOVED***if case .packageFailure = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED***if case .downloading = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***if case .downloaded = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED******REMOVED***case .downloadFailure:
***REMOVED******REMOVED******REMOVED***if case .downloadFailure = other { true ***REMOVED*** else { false ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
