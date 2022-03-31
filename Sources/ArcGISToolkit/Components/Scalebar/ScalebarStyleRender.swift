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
    var barStyleRender: some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(fillColor)
                .border(
                    .white,
                    width: 1.5
                )
                .frame(
                    height: 7,
                    alignment: .leading
                )
                .shadow(
                    color: shadowColor,
                    radius: 1
                )
            HStack {
                Text("\($viewModel.displayLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
                    .font(font)
                    .fontWeight(.semibold)
                    .onSizeChange {
                        finalLengthWidth = $0.width
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    var lineStyleRender: some View {
        VStack(spacing: 2) {
            GeometryReader { geoProxy in
                ZStack(alignment: .bottom) {
                    Line.basicHorizontal(width: geoProxy.size.width)
                    HStack {
                        Line.basicVertical(height: geoProxy.size.height)
                        Spacer()
                        Line.basicVertical(height: geoProxy.size.height)
                    }
                }
                .compositingGroup()
                .shadow(
                    color: shadowColor,
                    radius: 1
                )
            }
            .frame(height: 10)
            HStack {
                Text("\($viewModel.displayLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
                    .font(font)
                    .fontWeight(.semibold)
                    .onSizeChange {
                        finalLengthWidth = $0.width
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
}
