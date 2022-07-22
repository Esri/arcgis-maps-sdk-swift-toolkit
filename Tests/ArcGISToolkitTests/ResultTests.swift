// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import XCTest
@testable import ArcGISToolkit

class ResultTests: XCTestCase {
    /// Tests the conversion of a cancellation error result to `nil.`
    func testCancellationToNil() {
        var result: Result<String, Error> = .success("hello")
        XCTAssertNotNil(result.cancellationToNil())
        
        struct MockError: Error {}
        result = .failure(MockError())
        XCTAssertNotNil(result.cancellationToNil())
        
        result = .failure(CancellationError())
        XCTAssertNil(result.cancellationToNil())
    }
}
