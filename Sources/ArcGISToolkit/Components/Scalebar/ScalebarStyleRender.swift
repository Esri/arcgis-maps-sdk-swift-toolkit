***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

extension Scalebar {
***REMOVED***var alternatingBarStyleRender: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***HStack(spacing: -lineWidth) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.segments, id: \Scalebar.Segment.index) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill($0.index % 2 == 0 ? fillColor1 : fillColor2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: lineWidth
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***height: barFrameHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.compositingGroup()
***REMOVED******REMOVED******REMOVED***.cornerRadius(lineCornerRadius)
***REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED***color: shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED***radius: shadowRadius
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.segments, id: \Scalebar.Segment.index) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Scalebar.font.Font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: textShadowColor, radius: shadowRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(x: $0.xOffset, y: $0.yOffset)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var barStyleRender: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(fillColor2)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: lineWidth
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: barFrameHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: shadowRadius
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(lineCornerRadius)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\($viewModel.displayLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Scalebar.font.Font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: textShadowColor, radius: shadowRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finalLengthWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var lineStyleRender: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geoProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geoProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geoProxy.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(lineColor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.compositingGroup()
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: shadowRadius
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: lineFrameHeight)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\($viewModel.displayLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Scalebar.font.Font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: textShadowColor, radius: shadowRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finalLengthWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var dualUnitLineStyleRender: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geoProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geoProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geoProxy.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let midY = maxY / 2
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let alternateUnitX = viewModel.alternateUnitLength
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Leading vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Horiontal cross bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Unit 1 vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: maxX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Unit 2 vertical bar
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: alternateUnitX, y: midY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: alternateUnitX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(lineColor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.compositingGroup()
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: shadowRadius
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: barFrameHeight)
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("0")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Scalebar.font.Font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: textShadowColor, radius: shadowRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: -10)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var graduatedLineStyleRender: some View {
***REMOVED******REMOVED***VStack(spacing: Scalebar.labelYPad) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geoProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let segments = viewModel.segments
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let zero = Double.zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxX = geoProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let maxY = geoProxy.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: zero, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: zero, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: maxX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for segment in segments {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if segment.index == segments.last?.index {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let segmentX = segment.xOffset
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: segmentX, y: zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: segmentX, y: maxY))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineWidth: lineWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineCap: .round,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineJoin: .round
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(lineColor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.compositingGroup()
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: shadowRadius
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(height: lineFrameHeight)
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.segments, id: \Scalebar.Segment.index) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(Scalebar.font.Font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: textShadowColor, radius: shadowRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(x: $0.xOffset, y: $0.yOffset)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension Scalebar {
***REMOVED***struct Segment {
***REMOVED******REMOVED***var index: Int
***REMOVED******REMOVED***var segmentScreenLength: CGFloat
***REMOVED******REMOVED***var xOffset: CGFloat
***REMOVED******REMOVED***var yOffset: CGFloat
***REMOVED******REMOVED***var segmentMapLength: Double
***REMOVED******REMOVED***var text: String
***REMOVED******REMOVED***var textWidth: CGFloat
***REMOVED***
***REMOVED***
