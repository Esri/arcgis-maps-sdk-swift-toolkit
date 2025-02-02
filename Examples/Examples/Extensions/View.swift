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

import SwiftUI

extension View {
    /// Performs an action when a specified value changes.
    /// - Note: This is temporary until our minumum platform versions are increased.
    /// Without this a warning will show saying we are using a deprecated `onChange(of:perform:)` method.
    /// - Parameters:
    ///   - value: The value to check when determining whether to run the
    ///     closure.
    ///   - action: A closure to run when the value changes. The closure
    ///     takes a `newValue` parameter that indicates the updated
    ///     value.
    /// - Returns: A view that runs an action when the specified value changes.
    func onChange<V>(
        _ value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some View where V: Equatable {
        if #available(iOS 17.0, macCatalyst 17.0, visionOS 1.0, *) {
            return onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
}
