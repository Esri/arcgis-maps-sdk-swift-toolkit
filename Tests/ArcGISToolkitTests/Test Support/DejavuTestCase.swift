***REMOVED*** Copyright 2023 Esri
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

***REMOVED***
import Dejavu
import XCTest

class DejavuTestCase: XCTestCase {
***REMOVED***override func setUp() {
***REMOVED******REMOVED***let config = DejavuConfiguration(
***REMOVED******REMOVED******REMOVED***fileURL: .testDataDirectory.appendingPathComponent(mockDataSubpath),
***REMOVED******REMOVED******REMOVED***mode: .playback
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Dejavu.setURLProtocolRegistrationHandler { protocolClass in
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.urlSession = ArcGISURLSession {
***REMOVED******REMOVED******REMOVED******REMOVED***let config = URLSessionConfiguration.default
***REMOVED******REMOVED******REMOVED******REMOVED***config.protocolClasses = [protocolClass]
***REMOVED******REMOVED******REMOVED******REMOVED***return config
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Dejavu.setURLProtocolUnregistrationHandler { protocolClass in
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.urlSession = ArcGISURLSession  {
***REMOVED******REMOVED******REMOVED******REMOVED***URLSessionConfiguration.default
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Dejavu.startSession(configuration: config)
***REMOVED***
***REMOVED***
***REMOVED***override func tearDown() {
***REMOVED******REMOVED***Dejavu.endSession()
***REMOVED***
***REMOVED***

private extension XCTest {
***REMOVED******REMOVED***/ Generates a path with the name of the test case class followed by the name of the test case.
***REMOVED***var mockDataSubpath: String {
***REMOVED******REMOVED***let uniqueName = name.dropFirst(2)
***REMOVED******REMOVED******REMOVED***.dropLast()
***REMOVED******REMOVED******REMOVED***.replacingOccurrences(of: " ", with: ".")
***REMOVED******REMOVED***let testPathAndfileName = "\(uniqueName.replacingOccurrences(of: ".", with: "/")).sqlite"
***REMOVED******REMOVED***return testPathAndfileName
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED******REMOVED***/ The `URL` of the mocked data directory.
***REMOVED***static let testDataDirectory: URL = {
***REMOVED******REMOVED***return URL(fileURLWithPath: #file)
***REMOVED******REMOVED******REMOVED***.deletingLastPathComponent()
***REMOVED******REMOVED******REMOVED***.appendingPathComponent("Data")
***REMOVED***()
***REMOVED***
