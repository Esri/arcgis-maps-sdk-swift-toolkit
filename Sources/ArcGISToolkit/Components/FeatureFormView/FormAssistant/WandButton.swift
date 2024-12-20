// Copyright 2024 Esri
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

struct WandButton: View {
    /// <#Description#>
    @State private var colors: [Color] = Color.rainbow
    
    /// <#Description#>
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "wand.and.sparkles")
                .overlay {
                    AngularGradient(colors: colors, center: .center)
                        .onAppear {
                            withAnimation(.linear(duration: 1.0).repeatForever()) {
                                colors.shuffle()
                            }
                        }
                        .mask {
                            Image(systemName: "wand.and.sparkles")
                        }
                }
        }
        .wiggleEffect()
    }
}

private extension View {
    @ViewBuilder
    func wiggleEffect() -> some View {
        if #available(iOS 18.0, *) {
            self.symbolEffect(.wiggle, options: .repeat(.continuous))
        } else {
            self
        }
    }
}

#Preview {
    WandButton {
        
    }
    .font(.largeTitle)
}

extension Color {
    static var rainbow: [Self] {
        [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    }
}
