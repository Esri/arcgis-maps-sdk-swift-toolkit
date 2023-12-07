// Copyright 2023 Esri
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

import ArcGIS
import Dejavu
import XCTest

class DejavuTestCase: XCTestCase {
    override func setUp() {
        let config = DejavuConfiguration(
            fileURL: .testDataDirectory.appendingPathComponent(mockDataSubpath),
            mode: .playback
        )
        
        Dejavu.setURLProtocolRegistrationHandler { protocolClass in
            ArcGISEnvironment.urlSession = ArcGISURLSession {
                let config = URLSessionConfiguration.default
                config.protocolClasses = [protocolClass]
                return config
            }
        }
        
        Dejavu.setURLProtocolUnregistrationHandler { protocolClass in
            ArcGISEnvironment.urlSession = ArcGISURLSession  {
                URLSessionConfiguration.default
            }
        }
        
        Dejavu.startSession(configuration: config)
    }
    
    override func tearDown() {
        Dejavu.endSession()
    }
}

private extension XCTest {
    /// Generates a path with the name of the test case class followed by the name of the test case.
    var mockDataSubpath: String {
        let uniqueName = name.dropFirst(2)
            .dropLast()
            .replacingOccurrences(of: " ", with: ".")
        let testPathAndfileName = "\(uniqueName.replacingOccurrences(of: ".", with: "/")).sqlite"
        return testPathAndfileName
    }
}

private extension URL {
    /// The `URL` of the mocked data directory.
    static let testDataDirectory: URL = {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Data")
    }()
}
