// Copyright 2022 Esri.

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

/// A modifier which "selects" a button.  If selected the button will display with the
/// `BorderedProminentButtonStyle`.  If not selected, the button will display with the
/// `BorderedButtonStyle`.
struct ButtonSelectedModifier: ViewModifier {
    /// `true` if the view should display as selected, `false` otherwise.
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content
                .buttonStyle(BorderedProminentButtonStyle())
        } else {
            content
                .buttonStyle(BorderedButtonStyle())
        }
    }
}

extension Button {
    /// Button modifier used to denote the button is selected.
    /// - Parameter isSelected: `true` if the button is selected, `false` otherwise.
    /// - Returns: The button being modified.
    func buttonSelected(
        _ isSelected: Bool = false
    ) -> some View {
        modifier(ButtonSelectedModifier(isSelected: isSelected))
    }
}
