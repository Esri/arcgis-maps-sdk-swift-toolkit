// Copyright 2021 Esri.

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

struct EsriBorderViewModifier: ViewModifier {
    var edgeInsets: EdgeInsets
    func body(content: Content) -> some View {
        let roundedRect = RoundedRectangle(cornerRadius: 8)
        content
            .padding(edgeInsets)
            .background(.white)
            .clipShape(roundedRect)
            .overlay(
                roundedRect
                    .stroke(lineWidth: 2)
                    .foregroundColor(.blue)
            )
            .shadow(color: Color.gray.opacity(0.6),
                    radius: 3,
                    x: 1,
                    y: 2
            )
    }
}

extension View {
    func esriBorder(
        edgeInsets: EdgeInsets = EdgeInsets(
            top: 8,
            leading: 12,
            bottom: 8,
            trailing: 12
        )
    ) -> some View {
        return ModifiedContent(
            content: self,
            modifier: EsriBorderViewModifier(edgeInsets: edgeInsets)
        )
    }
}
