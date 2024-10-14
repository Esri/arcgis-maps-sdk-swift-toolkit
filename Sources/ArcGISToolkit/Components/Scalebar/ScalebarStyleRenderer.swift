// Copyright 2022 Esri
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

extension Scalebar {
    /// Renders all of the scalebar labels.
    var allLabelsView: some View {
        ZStack {
            ForEach(viewModel.labels, id: \.index) {
                Text($0.text)
                    .scalebarText()
                    .position(
                        x: $0.xOffset,
                        y: ScalebarLabel.yOffset
                    )
            }
        }
        .frame(height: Scalebar.fontHeight)
    }
    
    /// Renders a scalebar with `ScalebarStyle.alternatingBar`.
    var alternatingBarStyleRenderer: some View {
        VStack(spacing: Scalebar.labelYPad) {
            HStack(spacing: -Scalebar.lineWidth) {
                ForEach(viewModel.labels.dropFirst(), id: \.index) {
                    Rectangle()
                        .fill($0.index.isMultiple(of: 2) ? settings.fillColor1 : settings.fillColor2)
                        .border(
                            settings.lineColor,
                            width: Scalebar.lineWidth
                        )
                }
            }
            .frame(
                height: Scalebar.barFrameHeight,
                alignment: .leading
            )
            .cornerRadius(settings.barCornerRadius)
            .scalebarShadow()
            allLabelsView
        }
    }
    
    /// Renders a scalebar with `ScalebarStyle.bar`.
    var barStyleRenderer: some View {
        VStack(spacing: Scalebar.labelYPad) {
            Rectangle()
                .fill(settings.fillColor2)
                .border(
                    settings.lineColor,
                    width: Scalebar.lineWidth
                )
                .frame(
                    height: Scalebar.barFrameHeight,
                    alignment: .leading
                )
                .cornerRadius(settings.barCornerRadius)
                .scalebarShadow()
            Text(viewModel.labels.last?.text ?? "")
                .scalebarText()
        }
    }
    
    /// Renders a scalebar with `ScalebarStyle.dualUnitLine`.
    var dualUnitLineStyleRenderer: some View {
        VStack(spacing: Scalebar.labelYPad) {
            Text(viewModel.labels.last?.text ?? "")
                .scalebarText()
                .position(
                    x: viewModel.labels.last?.xOffset ?? .zero,
                    y: ScalebarLabel.yOffset
                )
                .frame(height: Scalebar.fontHeight)
            GeometryReader { geometry in
                Path { path in
                    let zero = Double.zero
                    let maxX = geometry.size.width
                    let maxY = geometry.size.height
                    let midY = maxY / 2
                    let alternateUnitX = viewModel.alternateUnit.screenLength
                    
                    // Leading vertical bar
                    path.move(to: CGPoint(x: zero, y: zero))
                    path.addLine(to: CGPoint(x: zero, y: maxY))
                    
                    // Horizontal cross bar
                    path.move(to: CGPoint(x: zero, y: midY))
                    path.addLine(to: CGPoint(x: maxX, y: midY))
                    
                    // Unit 1 vertical bar
                    path.move(to: CGPoint(x: maxX, y: zero))
                    path.addLine(to: CGPoint(x: maxX, y: midY))
                    
                    // Unit 2 vertical bar
                    path.move(to: CGPoint(x: alternateUnitX, y: midY))
                    path.addLine(to: CGPoint(x: alternateUnitX, y: maxY))
                }
                .stroke(
                    style: .init(
                        lineWidth: Scalebar.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .fill(settings.lineColor)
                .scalebarShadow()
            }
            .frame(height: Scalebar.barFrameHeight)
            Text(viewModel.alternateUnit.label)
                .scalebarText()
                .position(
                    x: viewModel.alternateUnit.screenLength,
                    y: ScalebarLabel.yOffset
                )
                .frame(height: Scalebar.fontHeight)
        }
        // Despite the language direction, this renderer should always place labels on the right.
        .environment(\.layoutDirection, .leftToRight)
    }
    
    /// Renders a scalebar with `ScalebarStyle.graduatedLine`.
    var graduatedLineStyleRenderer: some View {
        VStack(spacing: Scalebar.labelYPad) {
            GeometryReader { geometry in
                Path { path in
                    let segments = viewModel.labels
                    let zero = Double.zero
                    let maxX = geometry.size.width
                    let maxY = geometry.size.height
                    path.move(to: CGPoint(x: zero, y: maxY))
                    path.addLine(to: CGPoint(x: maxX, y: maxY))
                    for segment in segments {
                        let segmentX = segment.xOffset
                        path.move(to: CGPoint(x: segmentX, y: zero))
                        path.addLine(to: CGPoint(x: segmentX, y: maxY))
                    }
                }
                .stroke(
                    style: .init(
                        lineWidth: Scalebar.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .fill(settings.lineColor)
                .scalebarShadow()
            }
            .frame(height: Scalebar.lineFrameHeight)
            allLabelsView
        }
    }
    
    /// Renders a scalebar with `ScalebarStyle.line`.
    var lineStyleRenderer: some View {
        VStack(spacing: Scalebar.labelYPad) {
            GeometryReader { geometry in
                Path { path in
                    let zero = Double.zero
                    let maxX = geometry.size.width
                    let maxY = geometry.size.height
                    path.move(to: CGPoint(x: zero, y: zero))
                    path.addLine(to: CGPoint(x: zero, y: maxY))
                    path.addLine(to: CGPoint(x: maxX, y: maxY))
                    path.addLine(to: CGPoint(x: maxX, y: zero))
                }
                .stroke(
                    style: .init(
                        lineWidth: Scalebar.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .fill(settings.lineColor)
                .scalebarShadow()
            }
            .frame(height: Scalebar.lineFrameHeight)
            Text(viewModel.labels.last?.text ?? "")
                .scalebarText()
        }
    }
}
