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

public extension Result where Failure == Error {
    /// Creates a result based on the outcome of the given task. If the task
    /// succeeds, the result is `success`. If the task fails, the result is
    /// `failure`.
    init(awaiting task: @Sendable () async throws -> Success) async {
        do {
            self = .success(try await task())
        } catch {
            self = .failure(error)
        }
    }
    
    /// Converts the result to a `nil` in the case of a user cancelled error.
    /// - Returns: `Self` or `nil` if there was a cancellation error.
    /// - Attention: Deprecated at 200.3.
    @available(*, deprecated, message: "Check the 'failure' case for 'CancellationError' instead.")
    func cancellationToNil() -> Self? {
        guard case .failure(_ as CancellationError) = self else {
            return self
        }
        return nil
    }
}
