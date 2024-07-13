// Copyright 2021 Esri
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

import Combine

extension Publisher where Self: Sendable {
    /// Asynchronously returns the first value emitted from the publisher.
    /// This property will return `nil` if this publisher completes without an error before
    /// it emits a value.
    var first: Output? {
        get async throws {
            if let output = try await AsyncThrowingPublisher(self).first {
                return output
            } else if Task.isCancelled {
                throw CancellationError()
            } else {
                return nil
            }
        }
    }
}

extension AsyncSequence {
    /// The first element emitted by the async sequence.
    var first: Element? {
        get async throws {
            try await first { _ in true }
        }
    }
}
