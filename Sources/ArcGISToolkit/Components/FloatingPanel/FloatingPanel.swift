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
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Rectangle().foregroundColor(.blue)***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: 1.0)
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 8.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(4.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
***REMOVED***
***REMOVED******REMOVED***.frame(width: 300)
***REMOVED******REMOVED***.esriBorder(padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***

struct FloatingPanel_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***FloatingPanel(content: Rectangle().foregroundColor(.blue))
***REMOVED***
***REMOVED***
