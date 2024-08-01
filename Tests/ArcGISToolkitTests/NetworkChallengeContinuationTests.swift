// Copyright 2022 Esri
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

import SwiftUI
import XCTest
@testable import ArcGISToolkit

final class NetworkChallengeContinuationTests: XCTestCase {
    @MainActor
    func testInit() {
        let challenge = NetworkChallengeContinuation(host: "host.com", kind: .serverTrust)
        XCTAssertEqual(challenge.host, "host.com")
        XCTAssertEqual(challenge.kind, .serverTrust)
    }
    
    @MainActor
    func testResumeAndComplete() async {
        let challenge = NetworkChallengeContinuation(host: "host.com", kind: .serverTrust)
        challenge.resume(with: .continueWithCredential(.serverTrust))
        let disposition = await challenge.value
        XCTAssertEqual(disposition, .continueWithCredential(.serverTrust))
    }
}
