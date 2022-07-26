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

import WebKit
***REMOVED***

***REMOVED***/ A SwiftUI view to display an HTML string in a `WKWebView`.
struct HTMLTextView: UIViewRepresentable {
***REMOVED******REMOVED***/ The html string to dispay, including the header.
***REMOVED***var displayHTMLString: String
***REMOVED***
***REMOVED******REMOVED***/ The height of the view, calculated in the `webView(didFinish:)` delegate method.
***REMOVED***@Binding private var dynamicHeight: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The static header string for displaying html strings in a readable size.
***REMOVED***static var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header><style>body { font-family:-apple-system; font:-apple-system-subheadline ***REMOVED***</style>"
***REMOVED***static var footerString = "</p>"

***REMOVED******REMOVED***/ Creates an `HTMLTextView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - htmlString: The html string to be displayed.
***REMOVED******REMOVED***/   - dynamicHeight: A binding to the calculated height of the `WKWebView`.
***REMOVED***init(htmlString: String, dynamicHeight: Binding<CGFloat>) {
***REMOVED******REMOVED***displayHTMLString = HTMLTextView.headerString + htmlString + HTMLTextView.footerString
***REMOVED******REMOVED***_dynamicHeight = dynamicHeight
***REMOVED***
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> WKWebView {
***REMOVED******REMOVED***WKWebView()
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: WKWebView, context: Context) {
***REMOVED******REMOVED***uiView.backgroundColor = .clear
***REMOVED******REMOVED***uiView.navigationDelegate = context.coordinator
***REMOVED******REMOVED***uiView.loadHTMLString(displayHTMLString, baseURL: nil)
***REMOVED******REMOVED***uiView.scrollView.isScrollEnabled = false
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, WKNavigationDelegate {
***REMOVED******REMOVED***var parent: HTMLTextView
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(_ parent: HTMLTextView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** WKNavigationDelegate method for navigation actions.
***REMOVED******REMOVED***func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
***REMOVED******REMOVED******REMOVED***if navigationAction.navigationType == .linkActivated &&
***REMOVED******REMOVED******REMOVED******REMOVED***(navigationAction.request.url?.scheme?.lowercased() == "http" ||
***REMOVED******REMOVED******REMOVED******REMOVED*** navigationAction.request.url?.scheme?.lowercased() == "https") {
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let url = navigationAction.request.url {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(url)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***return .cancel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .allow
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** WKNavigationDelegate method where the size calculation happens.
***REMOVED******REMOVED***func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
***REMOVED******REMOVED******REMOVED***self.parent.dynamicHeight = webView.scrollView.contentSize.height
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(self)
***REMOVED***
***REMOVED***
