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

/// A modifier which "styles" a Text element's font, shadow color and radius.
struct ScalebarTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Scalebar.font.font)
            .foregroundColor(Scalebar.textColor)
            .shadow(
                color: Scalebar.textShadowColor,
                radius: Scalebar.shadowRadius
            )
    }
}
    
extension Text {
    func scalebarText() -> some View {
        modifier(
            ScalebarTextModifier()
        )
    }
}

/// A modifier which "styles" a scalebar's shadow color and radius.
struct ScalebarGroupShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .shadow(
                color: Scalebar.shadowColor,
                radius: Scalebar.shadowRadius
            )
    }
}
    
extension View {
    func scalebarShadow() -> some View {
        modifier(
            ScalebarGroupShadowModifier()
        )
    }
}
