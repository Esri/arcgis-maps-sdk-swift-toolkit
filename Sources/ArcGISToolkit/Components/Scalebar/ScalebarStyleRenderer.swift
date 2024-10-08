***REMOVED*** Copyright 2022 Esri
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

@available(visionOS, unavailable)
extension Scalebar {
***REMOVED******REMOVED***/ Renders all of the scalebar labels.
***REMOVED***var allLabelsView: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.labels, id: \.index) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text($0.text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scalebarText()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: $0.xOffset,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: ScalebarLabel.yOffset
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: Scalebar.fontHeight)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renders a scalebar with `ScalebarStyle.alternatingBar`.
***REMOVED***var alternatingBarStyleRenderer: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***HStack(spacing: -Scalebar.lineWidth) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.labels.dropFirst(), id: \.index) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill($0.index.isMultiple(of: 2) ? settings.fillColor1 : settings.fillColor2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***settings.lineColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: Scalebar.lineWidth
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***height: Scalebar.barFrameHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.cornerRadius(settings.barCornerRadius)
***REMOVED******REMOVED******REMOVED***.scalebarShadow()
***REMOVED******REMOVED******REMOVED***allLabelsView
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renders a scalebar with `ScalebarStyle.bar`.
***REMOVED***var barStyleRenderer: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(settings.fillColor2)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***settings.lineColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: Scalebar.lineWidth
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: Scalebar.barFrameHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(settings.barCornerRadius)
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarShadow()
***REMOVED******REMOVED******REMOVED***Text(viewModel.labels.last?.text ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarText()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renders a scalebar with `ScalebarStyle.dualUnitLine`.
***REMOVED***var dualUnitLineStyleRenderer: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***Text(viewModel.labels.last?.text ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarText()
***REMOVED******REMOVED******REMOVED******REMOVED***.position(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: viewModel.labels.last?.xOffset ?? .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: ScalebarLabel.yOffset
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: Scalebar.fontHeight)
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geometry.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let midY = maxY / 2
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let alternateUnitX = viewModel.alternateUnit.screenLength
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Leading vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Horizontal cross bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Unit 1 vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: maxX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Unit 2 vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: alternateUnitX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: alternateUnitX, y: maxY))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: Scalebar.lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(settings.lineColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarShadow()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: Scalebar.barFrameHeight)
***REMOVED******REMOVED******REMOVED***Text(viewModel.alternateUnit.label)
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarText()
***REMOVED******REMOVED******REMOVED******REMOVED***.position(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: viewModel.alternateUnit.screenLength,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: ScalebarLabel.yOffset
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: Scalebar.fontHeight)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Despite the language direction, this renderer should always place labels on the right.
***REMOVED******REMOVED***.environment(\.layoutDirection, .leftToRight)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renders a scalebar with `ScalebarStyle.graduatedLine`.
***REMOVED***var graduatedLineStyleRenderer: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let segments = viewModel.labels
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geometry.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for segment in segments {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let segmentX = segment.xOffset
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: segmentX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: segmentX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: Scalebar.lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(settings.lineColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarShadow()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: Scalebar.lineFrameHeight)
***REMOVED******REMOVED******REMOVED***allLabelsView
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renders a scalebar with `ScalebarStyle.line`.
***REMOVED***var lineStyleRenderer: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geometry.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: zero))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: Scalebar.lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(settings.lineColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarShadow()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: Scalebar.lineFrameHeight)
***REMOVED******REMOVED******REMOVED***Text(viewModel.labels.last?.text ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED***.scalebarText()
***REMOVED***
***REMOVED***
***REMOVED***
