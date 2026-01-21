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

extension XCTestCase {
    /// Skips the current test on the indicated platform(s).
    /// - Parameters:
    ///   - macCatalyst: Skip the test on Mac Catalyst.
    ///   - simulator: Skip the test on iOS and visionOS simulators.
    ///   - visionOS: Skip the test on visionOS devices and simulators.
    func skipIf(
        macCatalyst: Bool = false,
        simulator: Bool = false,
        visionOS: Bool = false
    ) throws {
#if targetEnvironment(macCatalyst)
        if macCatalyst {
            throw XCTSkip("Not supported on Mac Catalyst.")
        }
#endif
#if targetEnvironment(simulator)
        if simulator {
            throw XCTSkip("Not supported on iOS and visionOS simulators.")
        }
#endif
#if os(visionOS)
        if visionOS {
            throw XCTSkip("Not supported on visionOS devices and simulators.")
        }
#endif
    }
}
