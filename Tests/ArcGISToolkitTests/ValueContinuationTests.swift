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

import XCTest
@testable import ArcGISToolkit

final class ValueContinuationTests: XCTestCase {
    @MainActor
    func testValueContinuation() async {
        // Tests setting value before awaiting.
        let valueContinuation = ValueContinuation<String>()
        valueContinuation.setValue("hello")
        let value = await valueContinuation.value
        XCTAssertEqual(value, "hello")
        
        // Tests setting value after awaiting.
        let valueContinuation2 = ValueContinuation<Int>()
        Task { valueContinuation2.setValue(1) }
        let value2 = await valueContinuation2.value
        XCTAssertEqual(value2, 1)
    }
}
