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
    
    /// The identifier for the Carousel content.
    let contentIdentifier = UUID()
    
    /// The content shown in the Carousel.
    let content: (_: CGSize, _: (() -> Void)?) -> Content
    
    /// This number is used to compute the final width that allows for a partially visible cell.
    var cellBaseWidth = 120.0
    
    /// The horizontal spacing between each cell.
    var cellSpacing = 8.0
    
    /// The fractional width of the partially visible cell.
    var cellVisiblePortion = 0.25
    
    /// A horizontally scrolling container to display a set of content.
    /// - Parameter content: A view builder that creates the content of this Carousel.
    init(@ViewBuilder content: @escaping (_: CGSize, _: (() -> Void)?) -> Content) {
        self.content = content
    }
    
    /// - Note: The iOS 18 version currently uses `legacyImplementation` as
    /// `iOS18Implementation` contains symbols not available in Xcode 15.4.
    var body: some View {
        if #available(iOS 18.0, *) {
            legacyImplementation
        } else {
            legacyImplementation
        }
    }
    
    var legacyImplementation: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal) {
                    makeCommonScrollViewContent(scrollViewProxy)
                }
            }
            .onAppear {
                updateCellSizeForContainer(geometry.size.width)
            }
            .onChange(of: geometry.size.width) { width in
                updateCellSizeForContainer(width)
            }
        }
        // When a GeometryReader is within a List, height must be specified.
        .frame(height: cellSize.height)
    }
    
//    The iOS 18 implementation is commented as it contains symbols not
//    available in Xcode 15.4.
//    @available(iOS 18.0, *)
//    var iOS18Implementation: some View {
//        ScrollViewReader { scrollViewProxy in
//            ScrollView(.horizontal) {
//                makeCommonScrollViewContent(scrollViewProxy)
//            }
//        }
//        .onScrollGeometryChange(for: CGFloat.self) { geometry in
//            geometry.containerSize.width
//        } action: { _, newValue in
//            updateCellSizeForContainer(newValue)
//        }
//    }
    
    func makeCommonScrollViewContent(_ scrollViewProxy: ScrollViewProxy) -> some View {
        HStack(spacing: cellSpacing) {
            content(cellSize) {
                withAnimation {
                    scrollViewProxy.scrollTo(contentIdentifier, anchor: .leading)
                }
            }
            .id(contentIdentifier)
            .frame(width: cellSize.width, height: cellSize.height)
            .clipped()
        }
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

#Preview("cellBaseWidth(_:)") {
    Carousel { _, _ in
        PreviewContent()
    }
    .cellBaseWidth(75)
}

#Preview("cellSpacing(_:)") {
    Carousel { _, _ in
        PreviewContent()
    }
    .cellSpacing(2)
}

#Preview("cellVisiblePortion(_:)") {
    Carousel { _, _ in
        PreviewContent()
    }
    .cellVisiblePortion(0.5)
}

#Preview("In a List") {
    List {
        Text("Hello")
        Carousel { _, _ in
            PreviewContent()
        }
        Text("World!")
    }
}

#Preview("Scroll to left action") {
    struct ScrollDemo: View {
        @State var scrollToLeftAction: (() -> Void)?
        
        var body: some View {
            Carousel { _, scrollToLeftAction in
                ForEach(1..<11) {
                    Text($0.description)
                        .id($0)
                }
                .onAppear {
                    self.scrollToLeftAction = scrollToLeftAction
                }
            }
            Button("Scroll to 1") {
                withAnimation {
                    scrollToLeftAction?()
                }
            }
        }
    }
    
    return ScrollDemo()
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
