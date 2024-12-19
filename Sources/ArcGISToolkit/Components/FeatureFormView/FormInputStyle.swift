// Copyright 2023 Esri
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

/// Provides a frame minimum height constraint, padding, background color and rounded corners for a
/// form input.
struct FormInputStyle: ViewModifier {
    let assistedStyle: Bool
    
    @State private var colors: [Color] = [.red, .yellow, .green, .blue]
    
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 30)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                if assistedStyle {
                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                        .blur(radius: 50)
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever()) {
                                colors.shuffle()
                            }
                        }
                        .allowsHitTesting(false)
                } else {
                    Color(uiColor: .tertiarySystemFill)
                }
            }
            .cornerRadius(10)
    }
}

extension View {
    /// Provides a frame minimum height constraint, padding, background color and rounded corners
    /// for a form input.
    func formInputStyle(assistedStyle: Bool = false) -> some View {
        modifier(FormInputStyle(assistedStyle: assistedStyle))
    }
}
