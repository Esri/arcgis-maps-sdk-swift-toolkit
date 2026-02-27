// Copyright 2026 Esri
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

extension XCUIElement {
    /// Asserts that the element exists after an amount of time.
    /// - Parameters:
    ///   - timeout: The time, in seconds, the test allows for the element to become available. The
    ///   default timeout is five seconds.
    @MainActor func assertExistence(
        timeout: TimeInterval = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            "The \(description) wasn't found after \(timeout) \(timeout == 1 ? "second" : "seconds").",
            file: file,
            line: line
        )
    }
    
    /// Asserts that the element exists after an amount of time and then sends a tap event to it.
    /// - Parameters:
    ///   - timeout: The time, in seconds, the test allows for the element to become available. The
    ///   default timeout is five seconds.
    @MainActor func assertExistenceAndTap(
        timeout: TimeInterval = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertExistence(file: file, line: line)
        tap()
    }
    
    /// Asserts that the element does not exist after an amount of time.
    /// - Parameters:
    ///   - timeout: The time, in seconds, the test allows for the element to become unavailable. The
    ///   default timeout is five seconds.
    @MainActor func assertNonExistence(
        timeout: TimeInterval = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            waitForNonExistence(timeout: timeout),
            "The \(description) was still present after \(timeout) \(timeout == 1 ? "second" : "seconds").",
            file: file,
            line: line
        )
    }
}

private extension TimeInterval {
    /// A 5 second time interval.
    static var standard: TimeInterval { 5 }
}
