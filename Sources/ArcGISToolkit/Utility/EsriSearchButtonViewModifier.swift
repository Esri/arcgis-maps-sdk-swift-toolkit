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

/// A modifier which adds a "search" button in a view, used to initiate an operation.
struct EsriSearchButtonViewModifier: ViewModifier {
    var action: () -> Void
    
    func body(content: Content) -> some View {
        HStack {
            Button(
                action: action,
                label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .foregroundColor(Color(.opaqueSeparator))
                }
            )
            content
        }
    }
}

extension View {
    func esriSearchButton(_ action: @escaping () -> Void) -> some View {
        ModifiedContent(
            content: self,
            modifier: EsriSearchButtonViewModifier(action: action)
        )
    }
}
