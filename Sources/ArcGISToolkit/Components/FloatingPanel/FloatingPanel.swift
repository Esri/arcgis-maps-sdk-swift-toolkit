***REMOVED***.

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
***REMOVED******REMOVED***

public struct FloatingPanel<Content> : View where Content : View {
***REMOVED******REMOVED***/ The content that is to be housed in the floating panel.
***REMOVED***let content: Content
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***content: Content
***REMOVED***) {
***REMOVED******REMOVED***self.content = content
***REMOVED***
***REMOVED***
***REMOVED***@State
***REMOVED***var handleColor: Color = .secondary
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { self.heightOffset = $0.translation.height***REMOVED***
***REMOVED******REMOVED******REMOVED***.onChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***self.handleColor = .red
***REMOVED******REMOVED******REMOVED******REMOVED***self.heightOffset = $0.translation.height
***REMOVED******REMOVED******REMOVED******REMOVED***lastHeight = originalHeight + heightOffset
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***self.handleColor = .secondary
***REMOVED******REMOVED******REMOVED******REMOVED***self.originalHeight = lastHeight
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State
***REMOVED***private var heightOffset: CGFloat = 0
***REMOVED***
***REMOVED***@State
***REMOVED***private var originalHeight: CGFloat = 0
***REMOVED***@State
***REMOVED***private var lastHeight: CGFloat = 0

***REMOVED******REMOVED******REMOVED***private var currentHeight: CGFloat = 0
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: originalHeight + heightOffset)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if originalHeight == 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***originalHeight = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: 1.0)
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 8.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(4.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
***REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED***Text("\(self.heightOffset)")
***REMOVED***
***REMOVED******REMOVED***.frame(width: 300)
***REMOVED******REMOVED***.esriBorder(padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
***REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***

struct FloatingPanel_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***FloatingPanel(content: Rectangle().foregroundColor(.blue))
***REMOVED***
***REMOVED***
