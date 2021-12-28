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

public struct FloatingPanel<Content> : View where Content : View {
***REMOVED******REMOVED***/ The content that is to be housed in the floating panel.
***REMOVED***let content: Content
***REMOVED***
***REMOVED***public init(content: Content) {
***REMOVED******REMOVED***self.content = content
***REMOVED***
***REMOVED***
***REMOVED***@State
***REMOVED***var handleColor: Color = .secondary

***REMOVED***@State
***REMOVED***var height: CGFloat? = nil
***REMOVED***
***REMOVED***private let minHeight: CGFloat = 66
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: minHeight, maxHeight: height)
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 8.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(4.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriBorder(padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture()
***REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED***self.handleColor = .red
***REMOVED******REMOVED******REMOVED******REMOVED***height = max(minHeight, (height ?? 0) + value.translation.height)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***self.handleColor = .secondary
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
