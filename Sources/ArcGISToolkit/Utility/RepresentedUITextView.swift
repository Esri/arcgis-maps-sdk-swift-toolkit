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

***REMOVED***/ A represented `UITextView`.
***REMOVED***/
***REMOVED***/ A `UITextView` has noticeably better performance over a SwiftUI `TextField` when dealing with
***REMOVED***/ large input (e.g. thousands of characters).
struct RepresentedUITextView: UIViewRepresentable {
***REMOVED***@Binding var text: String
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> UITextView {
***REMOVED******REMOVED***let uiTextView = UITextView()
***REMOVED******REMOVED***uiTextView.delegate = context.coordinator
***REMOVED******REMOVED***return uiTextView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiTextView: UITextView, context: Context) {
***REMOVED******REMOVED***uiTextView.text = text
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(text: $text)
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, UITextViewDelegate {
***REMOVED******REMOVED***var text: Binding<String>
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(text: Binding<String>) {
***REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidChange(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***text.wrappedValue = textView.text
***REMOVED***
***REMOVED***
***REMOVED***
