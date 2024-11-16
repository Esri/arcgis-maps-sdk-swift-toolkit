***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ A view that arranges its subviews in a horizontal scrolling container.
***REMOVED***/
***REMOVED***/ The view can be configured to size subviews such that one is partially visible at all times.
struct Carousel<Content: View>: View {
***REMOVED******REMOVED***/ The size of each cell.
***REMOVED***@State private var cellSize = CGSize.zero
***REMOVED***
***REMOVED******REMOVED***/ The identifier for the Carousel content.
***REMOVED***@State private var contentIdentifier = UUID()
***REMOVED***
***REMOVED******REMOVED***/ The content shown in the Carousel.
***REMOVED***let content: (_: CGSize, _: (() -> Void)?) -> Content
***REMOVED***
***REMOVED******REMOVED***/ The amount to offset the scroll indicator.
***REMOVED***let scrollIndicatorOffset = 10.0
***REMOVED***
***REMOVED******REMOVED***/ This number is used to compute the final width that allows for a partially visible cell.
***REMOVED***var cellBaseWidth = 120.0
***REMOVED***
***REMOVED******REMOVED***/ The horizontal spacing between each cell.
***REMOVED***var cellSpacing = 8.0
***REMOVED***
***REMOVED******REMOVED***/ The fractional width of the partially visible cell.
***REMOVED***var cellVisiblePortion = 0.25
***REMOVED***
***REMOVED******REMOVED***/ A horizontally scrolling container to display a set of content.
***REMOVED******REMOVED***/ - Parameter content: A view builder that creates the content of this Carousel.
***REMOVED***init(@ViewBuilder content: @escaping (_: CGSize, _: (() -> Void)?) -> Content) {
***REMOVED******REMOVED***self.content = content
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if #available(iOS 18.0, *) {
***REMOVED******REMOVED******REMOVED***iOS18Implementation
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***legacyImplementation
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var legacyImplementation: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeCommonScrollViewContent(scrollViewProxy)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***updateCellSizeForContainer(geometry.size.width)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(geometry.size.width) { width in
***REMOVED******REMOVED******REMOVED******REMOVED***updateCellSizeForContainer(width)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** When a GeometryReader is within a List, height must be specified.
***REMOVED******REMOVED***.frame(height: cellSize.height)
***REMOVED***
***REMOVED***
***REMOVED***@available(iOS 18.0, *)
***REMOVED***var iOS18Implementation: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED******REMOVED***makeCommonScrollViewContent(scrollViewProxy)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onScrollGeometryChange(for: CGFloat.self) { geometry in
***REMOVED******REMOVED******REMOVED***geometry.containerSize.width
***REMOVED*** action: { _, newValue in
***REMOVED******REMOVED******REMOVED***updateCellSizeForContainer(newValue)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCommonScrollViewContent(_ scrollViewProxy: ScrollViewProxy) -> some View {
***REMOVED******REMOVED***HStack(spacing: cellSpacing) {
***REMOVED******REMOVED******REMOVED***content(cellSize) {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewProxy.scrollTo(contentIdentifier, anchor: .leading)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.id(contentIdentifier)
***REMOVED******REMOVED******REMOVED***.frame(width: cellSize.width, height: cellSize.height)
***REMOVED******REMOVED******REMOVED***.clipped()
***REMOVED******REMOVED******REMOVED******REMOVED*** Pad the content such that the scroll indicator appears beneath it
***REMOVED******REMOVED******REMOVED******REMOVED*** so that the content is not covered. 
***REMOVED******REMOVED******REMOVED***.padding(.bottom, scrollIndicatorOffset)
***REMOVED***
***REMOVED***
***REMOVED***

extension Carousel {
***REMOVED******REMOVED***/ Updates `cellSize` based on the provided container width, `cellBaseWidth`,
***REMOVED******REMOVED***/ `cellSpacing`, and `visiblePortion` such that the `cellVisiblePortion` width of
***REMOVED******REMOVED***/ one cell is shown to indicate scrollability.
***REMOVED******REMOVED***/ - Parameter width: The width of the container the `AttachmentPreview` is in.
***REMOVED***func updateCellSizeForContainer(_ width: CGFloat) {
***REMOVED******REMOVED***let fullyVisible = modf(width / cellBaseWidth)
***REMOVED******REMOVED***let totalPadding = fullyVisible.0 * cellSpacing
***REMOVED******REMOVED***let newWidth = (width - totalPadding) / (fullyVisible.0 + cellVisiblePortion)
***REMOVED******REMOVED***cellSize = CGSize(width: newWidth, height: newWidth)
***REMOVED***
***REMOVED***
***REMOVED***func cellBaseWidth(_ width: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.cellBaseWidth = width
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED***func cellSpacing(_ spacing: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.cellSpacing = spacing
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED***func cellVisiblePortion(_ visiblePortion: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.cellVisiblePortion = visiblePortion
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

#Preview("cellBaseWidth(_:)") {
***REMOVED***Carousel { _, _ in
***REMOVED******REMOVED***PreviewContent()
***REMOVED***
***REMOVED***.cellBaseWidth(75)
***REMOVED***

#Preview("cellSpacing(_:)") {
***REMOVED***Carousel { _, _ in
***REMOVED******REMOVED***PreviewContent()
***REMOVED***
***REMOVED***.cellSpacing(2)
***REMOVED***

#Preview("cellVisiblePortion(_:)") {
***REMOVED***Carousel { _, _ in
***REMOVED******REMOVED***PreviewContent()
***REMOVED***
***REMOVED***.cellVisiblePortion(0.5)
***REMOVED***

#Preview("In a List") {
***REMOVED***List {
***REMOVED******REMOVED***Text(verbatim: "Hello")
***REMOVED******REMOVED***Carousel { _, _ in
***REMOVED******REMOVED******REMOVED***PreviewContent()
***REMOVED***
***REMOVED******REMOVED***Text(verbatim: "World!")
***REMOVED***
***REMOVED***

#Preview("Scroll to left action") {
***REMOVED***struct ScrollDemo: View {
***REMOVED******REMOVED***@State var scrollToLeftAction: (() -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Carousel { _, scrollToLeftAction in
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(1..<11) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.id($0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.scrollToLeftAction = scrollToLeftAction
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollToLeftAction?()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "Scroll to left")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***return ScrollDemo()
***REMOVED***

private struct PreviewContent: View {
***REMOVED***var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ForEach(colors, id: \.self) { color in
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(color)
***REMOVED***
***REMOVED***
***REMOVED***
