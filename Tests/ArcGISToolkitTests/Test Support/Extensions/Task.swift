// Copyright 2025 Esri
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

import Foundation
import QuartzCore

/// An error that signals a timeout has occurred.
struct TimeoutError: Error {}

extension Task {
    /// Yield until a condition is met or a timeout occurs.
    /// - Parameters:
    ///   - timeout: The interval at which a timeout error will occur.
    ///   - until: The condition to yield until.
    static func yield(
        timeout: TimeInterval,
        until condition: @escaping @Sendable () async -> Bool
    ) async throws where Failure == Never, Success == Never {
        try await Task<Void, any Error>(priority: .low) {
            let start = CACurrentMediaTime()
            repeat {
                await Task.yield()
                let now = CACurrentMediaTime()
                guard now - start < timeout else {
                    throw TimeoutError()
                }
            } while await !condition()
        }.value
    }
}
