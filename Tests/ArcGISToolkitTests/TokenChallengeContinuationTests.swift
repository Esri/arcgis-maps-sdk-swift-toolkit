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

final class TokenChallengeContinuationTests: XCTestCase {
    @MainActor
    func testInit() {
        let challenge = TokenChallengeContinuation(host: "host.com") { _ in
            fatalError()
        }
        
        XCTAssertEqual(challenge.host, "host.com")
        XCTAssertNotNil(challenge.tokenCredentialProvider)
    }
    
    @MainActor
    func testResumeWithLogin() async {
        struct MockError: Error {}
        
        let challenge = TokenChallengeContinuation(host: "host.com") { _ in
            throw MockError()
        }
        challenge.resume(with: .init(username: "user1", password: "1234"))
        
        let result = await challenge.value
        XCTAssertTrue(result.error is MockError)
    }
    
    @MainActor
    func testCancel() async {
        let challenge = TokenChallengeContinuation(host: "host.com") { _ in
            fatalError()
        }
        challenge.cancel()
        
        let result = await challenge.value
        XCTAssertEqual(result.value, .cancel)
    }
}

private extension Result {
    /// The error that is encapsulated in the failure case when this result is a failure.
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        case .success:
            return nil
        }
    }
    
    /// The success value that is encapsulated in the success case when this result is a success.
    var value: Success? {
        switch self {
        case .failure:
            return nil
        case .success(let value):
            return value
        }
    }
}
