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

/// A view that arranges its subviews in a horizontal scrolling container.
///
/// The view can be configured to size subviews such that one is partially visible at all times.
struct Carousel<Content: View>: View {
    /// The size of each cell.
    @State private var cellSize = CGSize.zero
    
    /// The content shown in the Carousel.
    let content: () -> Content
    
    /// This number is used to compute the final width that allows for a partially visible cell.
    var cellBaseWidth = 120.0
    
    /// The horizontal spacing between each cell.
    var cellSpacing = 8.0
    
    /// The fractional width of the partially visible cell.
    var cellVisiblePortion = 0.25
    
    /// A horizontally scrolling container to display a set of content.
    /// - Parameter content: A view builder that creates the content of this Carousel.
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                HStack(spacing: cellSpacing) {
                    content()
                        .frame(width: cellSize.width, height: cellSize.height)
                }
            }
            .onAppear {
                updateCellSizeForContainer(geometry.size.width)
            }
            .onChange(of: geometry.size.width) { width in
                updateCellSizeForContainer(width)
            }
        }
        .frame(height: cellSize.height)
    }
}

extension Carousel {
    /// Updates `cellSize` based on the provided container width, `cellBaseWidth`,
    /// `cellSpacing`, and `visiblePortion` such that the `cellVisiblePortion` width of
    /// one cell is shown to indicate scrollability.
    /// - Parameter width: The width of the container the `AttachmentPreview` is in.
    func updateCellSizeForContainer(_ width: CGFloat) {
        let fullyVisible = modf(width / cellBaseWidth)
        let totalPadding = fullyVisible.0 * cellSpacing
        let newWidth = (width - totalPadding) / (fullyVisible.0 + cellVisiblePortion)
        cellSize = CGSize(width: newWidth, height: newWidth)
    }
    
    func cellBaseWidth(_ width: CGFloat) -> Self {
        var copy = self
        copy.cellBaseWidth = width
        return copy
    }
    
    func cellSpacing(_ spacing: CGFloat) -> Self {
        var copy = self
        copy.cellSpacing = spacing
        return copy
    }
    
    func cellVisiblePortion(_ visiblePortion: CGFloat) -> Self {
        var copy = self
        copy.cellVisiblePortion = visiblePortion
        return copy
    }
}

#Preview("Custom base width") {
    Carousel {
        PreviewContent()
    }
    .cellBaseWidth(75)
}

#Preview("Custom spacing") {
    Carousel {
        PreviewContent()
    }
    .cellSpacing(2)
}

#Preview("Custom visible portion") {
    Carousel {
        PreviewContent()
    }
    .cellVisiblePortion(0.5)
}

#Preview("In a list") {
    List {
        Text("Hello")
        Carousel {
            PreviewContent()
        }
        Text("World!")
    }
}

private struct PreviewContent: View {
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    
    var body: some View {
        ForEach(colors, id: \.self) { color in
            Rectangle()
                .fill(color)
        }
    }
}
