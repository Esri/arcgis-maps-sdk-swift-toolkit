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

/// A modifier which adds a "delete text" button in a view, used to delete a given text string.
struct EsriDeleteTextButtonViewModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(
                    action: { text = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.opaqueSeparator))
                    }
                )
            }
        }
    }
}

extension View {
    func esriDeleteTextButton(text: Binding<String>) -> some View {
        modifier(EsriDeleteTextButtonViewModifier(text: text))
    }
}
