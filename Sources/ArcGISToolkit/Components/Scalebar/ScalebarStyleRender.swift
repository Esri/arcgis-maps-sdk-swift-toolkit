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
    var alternatingBarStyleRender: some View {
        VStack(spacing: Scalebar.labelYPad) {
            HStack(spacing: -lineWidth) {
                ForEach(viewModel.labels.dropFirst(), id: \.index) {
                    Rectangle()
                        .fill($0.index % 2 == 0 ? fillColor1 : fillColor2)
                        .border(
                            lineColor,
                            width: lineWidth
                        )
                }
            }
            .frame(
                height: barFrameHeight,
                alignment: .leading
            )
            .compositingGroup()
            .cornerRadius(lineCornerRadius)
            .shadow(
                color: shadowColor,
                radius: shadowRadius
            )
            ZStack {
                ForEach(viewModel.labels, id: \.index) {
                    Text($0.text)
                        .scalebarText(self)
                        .position(
                            x: $0.xOffset,
                            y: ScalebarLabel.yOffset
                        )
                }
            }
        }
    }
    
    var barStyleRender: some View {
        VStack(spacing: Scalebar.labelYPad) {
            Rectangle()
                .fill(fillColor2)
                .border(
                    lineColor,
                    width: lineWidth
                )
                .frame(
                    height: barFrameHeight,
                    alignment: .leading
                )
                .cornerRadius(lineCornerRadius)
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius
                )
            Text(viewModel.labels.last?.text ?? "")
                .scalebarText(self)
        }
    }
    
    var lineStyleRender: some View {
        VStack(spacing: Scalebar.labelYPad) {
            GeometryReader { geoProxy in
                ZStack(alignment: .bottom) {
                    Path { path in
                        let zero = Double.zero
                        let maxX = geoProxy.size.width
                        let maxY = geoProxy.size.height
                        path.move(to: CGPoint(x: zero, y: zero))
                        path.addLine(to: CGPoint(x: zero, y: maxY))
                        path.addLine(to: CGPoint(x: maxX, y: maxY))
                        path.addLine(to: CGPoint(x: maxX, y: zero))
                    }
                    .stroke(
                        style: .init(
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .fill(lineColor)
                }
                .compositingGroup()
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius
                )
            }
            .frame(height: lineFrameHeight)
            Text(viewModel.labels.last?.text ?? "")
                .scalebarText(self)
        }
    }
    
    var dualUnitLineStyleRender: some View {
        VStack(spacing: Scalebar.labelYPad) {
            ZStack {
                Text(viewModel.labels.last?.text ?? "")
                    .scalebarText(self)
                    .position(
                        x: viewModel.labels.last?.xOffset ?? .zero,
                        y: ScalebarLabel.yOffset
                    )
                    .frame(height: Scalebar.fontHeight)
            }
            GeometryReader { geoProxy in
                ZStack(alignment: .bottom) {
                    Path { path in
                        let zero = Double.zero
                        let maxX = geoProxy.size.width
                        let maxY = geoProxy.size.height
                        let midY = maxY / 2
                        let alternateUnitX = viewModel.alternateUnit.screenLength
                        
                        // Leading vertical bar
                        path.move(to: CGPoint(x: zero, y: zero))
                        path.addLine(to: CGPoint(x: zero, y: maxY))
                        
                        // Horiontal cross bar
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
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .fill(lineColor)
                }
                .compositingGroup()
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius
                )
            }
            .frame(height: barFrameHeight)
            ZStack {
                Text(viewModel.alternateUnit.label)
                    .scalebarText(self)
                    .position(
                        x: viewModel.alternateUnit.screenLength,
                        y: ScalebarLabel.yOffset
                    )
                    .frame(height: Scalebar.fontHeight)
            }
        }
    }
    
    var graduatedLineStyleRender: some View {
        VStack(spacing: Scalebar.labelYPad) {
            GeometryReader { geoProxy in
                ZStack(alignment: .bottom) {
                    Path { path in
                        let segments = viewModel.labels
                        let zero = Double.zero
                        let maxX = geoProxy.size.width
                        let maxY = geoProxy.size.height
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
                            lineWidth: lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .fill(lineColor)
                }
                .compositingGroup()
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius
                )
            }
            .frame(height: lineFrameHeight)
            ZStack {
                ForEach(viewModel.labels, id: \.index) {
                    Text($0.text)
                        .scalebarText(self)
                        .position(x: $0.xOffset, y: ScalebarLabel.yOffset)
                }
            }
        }
    }
}
