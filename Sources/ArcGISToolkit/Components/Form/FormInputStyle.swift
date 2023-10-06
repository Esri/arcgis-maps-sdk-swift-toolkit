// Copyright 2023 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// Provides a frame minimum height constraint, padding, background color and rounded corners for a
/// form input.
struct FormInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
//            .padding(4)
            .padding([.vertical], 4)
            .padding([.horizontal], 6)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(10)
    }
}

extension View {
    /// Provides a frame minimum height constraint, padding, background color and rounded corners
    /// for a form input.
    func formInputStyle() -> some View {
        modifier(FormInputStyle())
    }
}
