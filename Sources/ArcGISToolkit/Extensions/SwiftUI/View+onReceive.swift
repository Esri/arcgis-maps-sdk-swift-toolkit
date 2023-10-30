// Copyright 2023 Esri.

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

public extension View {
    /// Adds an action to perform when this view detects data emitted by the
    /// given async sequence. If `action` is `nil`, then the async sequence is not observed.
    /// - Parameters:
    ///   - sequence: The async sequence to observe.
    ///   - value: A value that, when changed, the `action` closure will be re-captured.
    ///   - action: The action to perform when a value is emitted by `sequence`.
    ///   The value emitted by `sequence` is passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `sequence` emits a value.
    @MainActor @ViewBuilder func onReceive<S, E>(
        _ sequence: S,
        id value: E,
        perform action: (@MainActor (S.Element) -> Void)?
    ) -> some View where S: AsyncSequence & Sendable, E: Swift.Equatable, S.Element: Sendable {
        if let action = action {
            task(id: value) {
                do {
                    for try await element in sequence {
                        action(element)
                    }
                } catch {}
            }
        } else {
            self
        }
    }
    
    /// Adds an action to perform when this view detects data emitted by the
    /// given async sequence. If `action` is `nil`, then the async sequence is not observed.
    /// - Parameters:
    ///   - sequence: The async sequence to observe.
    ///   - value: A value that, when changed, the `action` closure will be re-captured.
    ///   - action: The action to perform when a value is emitted by `sequence`.
    ///   The tuple value emitted by `sequence` is destructured and passed as individual parameters
    ///   to `action`.
    /// - Returns: A view that triggers `action` when `sequence` emits a value.
    @MainActor @ViewBuilder func onReceive<S, U, V, E>(
        _ sequence: S,
        id value: E,
        perform action: (@MainActor (U, V) -> Void)?
    ) -> some View where S: AsyncSequence & Sendable, S.Element == (U, V), E: Swift.Equatable, S.Element: Sendable {
        if let action = action {
            task(id: value) {
                do {
                    for try await element in sequence {
                        action(element.0, element.1)
                    }
                } catch {}
            }
        } else {
            self
        }
    }
    
    /// Adds an action to perform when this view detects data emitted by the
    /// given async sequence. If `action` is `nil`, then the async sequence is not observed.
    /// The `action` closure is captured the first time the view appears.
    /// - Parameters:
    ///   - sequence: The async sequence to observe.
    ///   - action: The action to perform when a value is emitted by `sequence`.
    ///   The value emitted by `sequence` is passed as a parameter to `action`.
    /// - Returns: A view that triggers `action` when `sequence` emits a value.
    @MainActor @ViewBuilder func onReceive<S>(
        _ sequence: S,
        perform action: (@MainActor (S.Element) -> Void)?
    ) -> some View where S: AsyncSequence & Sendable, S.Element: Sendable {
        if let action = action {
            task {
                do {
                    for try await element in sequence {
                        action(element)
                    }
                } catch {}
            }
        } else {
            self
        }
    }
}
