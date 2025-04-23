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

extension Button<Text> {
    /// Returns a button with the title "Cancel" and the given action.
    /// - Parameter action: The action to perform when the user triggers the
    /// button.
    /// - Returns: A button.
    static nonisolated func cancel(action: @escaping @MainActor () -> Void) -> Self {
        Button(role: .cancel, action: action) {
            Text(LocalizedStringResource.cancel)
        }
    }
    
    /// Returns a button with the title "Done" and the given action.
    /// - Parameter action: The action to perform when the user triggers the
    /// button.
    /// - Returns: A button.
    static nonisolated func done(action: @escaping @MainActor () -> Void) -> Self {
        Button(action: action) {
            Text.done
                .fontWeight(.semibold)
        }
    }
    
    /// Returns a button with the title "ok" and the given action.
    /// - Parameter action: The action to perform when the user triggers the
    /// button.
    /// - Returns: A button.
    static nonisolated func ok(action: @escaping @MainActor () -> Void) -> Self {
        Button(action: action) {
            Text(LocalizedStringResource.ok)
        }
    }
}
