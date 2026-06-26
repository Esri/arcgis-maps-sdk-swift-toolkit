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
    /// Manipulates a picker wheel element to change the value, based on a normalized position.
    /// - Parameters:
    ///   - index: The element index to use.
    ///   - value: The targeted value.
    /// - Note: This method is not supported on visionOS.
    func adjustPickerWheelElement(boundBy index: Int, to value: String) {
#if !os(visionOS)
        pickerWheels.element(boundBy: index).adjust(toPickerWheelValue: value)
#endif
    }
    
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
        assertExistence(timeout: timeout, file: file, line: line)
        tap()
    }
    
    /// Asserts that the system can compute a hit point for the element.
    func assertHittable(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            isHittable,
            "The \(description) isn't hittable.",
            file: file,
            line: line
        )
    }
    
    /// Asserts that the element's label equals an expected value after an amount of time.
    /// - Parameters:
    ///   - expectedLabel: The expected value of the label.
    func assertLabel(
        _ expectedLabel: String,
        timeout: TimeInterval = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "label == %@", expectedLabel)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(
            label,
            expectedLabel,
            "Expected label '\(expectedLabel)' but got '\(label)'.",
            file: file,
            line: line
        )
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
    
    /// A Boolean value indicating whether the element's string value is
    /// "1" (on) or "0" (off).
    var boolValue: Bool? {
        switch value as? String {
        case "1":
            true
        case "0":
            false
        default:
            nil
        }
    }
}

private extension TimeInterval {
    /// A 5 second time interval.
    static var standard: TimeInterval { 5 }
}
