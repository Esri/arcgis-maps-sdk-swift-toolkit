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
***REMOVED***

***REMOVED***/ A view displaying a `TextPopupElement`.
struct TextPopupElementView: View {
***REMOVED******REMOVED***/ The `PopupElement` to display.
***REMOVED***var popupElement: TextPopupElement
***REMOVED***
***REMOVED******REMOVED***/ The calculated height of the `HTMLTextView`.
***REMOVED***@State private var webViewHeight: CGFloat = .zero
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if !popupElement.text.isEmpty {
***REMOVED******REMOVED******REMOVED***let roundedRect = RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HTMLTextView(html: popupElement.text, height: $webViewHeight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(roundedRect)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: webViewHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***if webViewHeight == .zero {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Show `ProgressView` until `HTMLTextView` has set the height.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***roundedRect
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(Color.primary, lineWidth: 1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED***
