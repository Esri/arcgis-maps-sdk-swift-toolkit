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

/// SwiftUI `TextEditor` and `TextField` views have different styling. `TextField`s have
/// `textFieldStyle` and `TextEditor`s do not. This modifier allows for common styling.
struct FormTextEntryBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(2)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.secondary.opacity(0.5), lineWidth: 0.5)
            }
    }
}

extension View {
    /// Adds a common padding and border around form field text elements.
    func formTextEntryBorder() -> some View {
        modifier(FormTextEntryBorder())
    }
}
