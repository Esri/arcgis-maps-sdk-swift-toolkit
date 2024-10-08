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

import SwiftUI

/// A modifier which displays a 2 point width border and a shadow around a view.
@available(visionOS, unavailable)
struct EsriBorderViewModifier: ViewModifier {
    var padding: EdgeInsets
    
    func body(content: Content) -> some View {
        let roundedRect = RoundedRectangle(cornerRadius: 8)
        content
            .padding(padding)
            .background(Color(uiColor: .systemBackground))
            .clipShape(roundedRect)
            .overlay(
                roundedRect
                    .stroke(lineWidth: 2)
                    .foregroundColor(Color(uiColor: .separator))
            )
            .shadow(
                color: .gray.opacity(0.4),
                radius: 3,
                x: 1,
                y: 2
            )
    }
}

@available(visionOS, unavailable)
public extension View {
    func esriBorder(
        padding: EdgeInsets = .toolkitDefault
    ) -> some View {
        modifier(EsriBorderViewModifier(padding: padding))
    }
}
