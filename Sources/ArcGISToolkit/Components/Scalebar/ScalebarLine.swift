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

extension Scalebar {
    /// Provides simple and predictable line creation.
    struct Line {
        /// The stroke width used to produce a line.
        private static let strokeWidth = 4.0
        
        /// A basic line.
        private struct basic: View {
            /// The width of the line.
            var width: Double
            
            /// The color used to fill the line.
            let color: Color = .white
            
            var body: some View {
                Path { path in
                    path.move(to: CGPoint(x: Double.zero, y: .zero))
                    path.addLine(to: CGPoint(x: width, y: .zero))
                    path.addLine(to: CGPoint(x: width, y: strokeWidth))
                    path.addLine(to: CGPoint(x: .zero, y: strokeWidth))
                    path.addLine(to: CGPoint(x: Double.zero, y: .zero))
                }
                .fill(color)
            }
        }
        
        /// A horizontally oriented line
        struct basicHorizontal: View {
            /// The width of the line.
            var width: CGFloat
            
            var body: some View {
                basic(width: width)
                    .frame(width: width, height: strokeWidth)
                    .cornerRadius(strokeWidth/2)
            }
        }
        
        /// A vertically oriented line
        struct basicVertical: View {
            /// The height of the line.
            var height: CGFloat
            
            var body: some View {
                basic(width: height)
                    .rotationEffect(Angle(degrees: 90), anchor: .topLeading)
                    .offset(x: strokeWidth)
                    .frame(width: strokeWidth, height: height)
                    .cornerRadius(strokeWidth/2)
            }
        }
    }
}
