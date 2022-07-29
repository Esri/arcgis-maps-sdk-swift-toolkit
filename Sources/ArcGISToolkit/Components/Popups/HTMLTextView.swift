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
***REMOVED******REMOVED***/ The user-defined HTML string.
***REMOVED***var userHTML: String = ""
***REMOVED***
***REMOVED******REMOVED***/ The html string to dispay, including the header.
***REMOVED***var displayHTML: String {
***REMOVED******REMOVED******REMOVED*** Set the initial scale to 1, don't allow user scaling.
***REMOVED******REMOVED******REMOVED*** When we went to WKWebView from UIWebView, the content got smaller,
***REMOVED******REMOVED******REMOVED*** this fixes that and also doesn't allow the user to pinch to zoom.
***REMOVED******REMOVED***var header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Inject css in a head element to:
***REMOVED******REMOVED******REMOVED*** - word wrap long content such as urls
***REMOVED******REMOVED******REMOVED*** - set font family to default apple font
***REMOVED******REMOVED******REMOVED*** - set font size to subheadline
***REMOVED******REMOVED******REMOVED*** - remove padding from the body. Add some margin to separate from the border of the webview.
***REMOVED******REMOVED******REMOVED*** - limit images to a maximum width of 100%
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Also wrap the passed html fragment inside <html></html>
***REMOVED******REMOVED******REMOVED*** open/close tags so that these css styles will apply
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** In order to make hyperlinks match our
***REMOVED******REMOVED******REMOVED*** app tint we need to be passed a color
***REMOVED******REMOVED******REMOVED*** and to dynamically inject it into the
***REMOVED******REMOVED******REMOVED*** HTML/CSS
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***header = header.appending("""
***REMOVED******REMOVED******REMOVED******REMOVED***<html>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<head>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<style>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***html {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***word-wrap:break-word; font-family:-apple-system; font:-apple-system-subheadline;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***body {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***margin:10px; padding:0px;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***img {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***max-width: 100%;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***</style>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***</head>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<body>
***REMOVED******REMOVED******REMOVED******REMOVED***""")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The final string is the header + userHTML + closing
***REMOVED******REMOVED***return header.appending(userHTML.trimmingCharacters(in: .whitespacesAndNewlines)).appending("</body></html>")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The height of the view, calculated in the `webView(didFinish:)` delegate method.
***REMOVED***@Binding private var dynamicHeight: CGFloat

***REMOVED******REMOVED***/ Creates an `HTMLTextView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - html: The html string to be displayed.
***REMOVED******REMOVED***/   - dynamicHeight: A binding to the calculated height of the `WKWebView`.
***REMOVED***init(html: String, dynamicHeight: Binding<CGFloat>) {
***REMOVED******REMOVED***userHTML = html
***REMOVED******REMOVED***_dynamicHeight = dynamicHeight
***REMOVED***
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> WKWebView {
***REMOVED******REMOVED***WKWebView()
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: WKWebView, context: Context) {
***REMOVED******REMOVED***uiView.isOpaque = false
***REMOVED******REMOVED******REMOVED*** This is a case where we always want the background to be white regardless of light/dark mode. If the user wants to implement dark mode,
***REMOVED******REMOVED******REMOVED*** within their HTML, the background of the HTML will be shown over this background.
***REMOVED******REMOVED***uiView.backgroundColor = .white
***REMOVED******REMOVED***uiView.scrollView.backgroundColor = .white
***REMOVED******REMOVED***uiView.scrollView.isScrollEnabled = false
***REMOVED******REMOVED***uiView.loadHTMLString(displayHTML, baseURL: nil)
***REMOVED******REMOVED***uiView.navigationDelegate = context.coordinator
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, WKNavigationDelegate {
***REMOVED******REMOVED***var parent: HTMLTextView
***REMOVED******REMOVED***
***REMOVED******REMOVED***private var hasCommitted = false

***REMOVED******REMOVED***init(_ parent: HTMLTextView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
***REMOVED******REMOVED******REMOVED***hasCommitted = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** WKNavigationDelegate method for navigation actions.
***REMOVED******REMOVED***func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
***REMOVED******REMOVED******REMOVED***if navigationAction.navigationType == .linkActivated,
***REMOVED******REMOVED******REMOVED***   (navigationAction.request.url?.scheme?.lowercased() == "http" ||
***REMOVED******REMOVED******REMOVED******REMOVED***navigationAction.request.url?.scheme?.lowercased() == "https"),
***REMOVED******REMOVED******REMOVED***   let url = navigationAction.request.url {
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(url)
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
***REMOVED******REMOVED******REMOVED***webView.evaluateJavaScript("document.readyState") { [weak self] complete, _ in
***REMOVED******REMOVED******REMOVED******REMOVED***guard complete != nil, let webView = webView  else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Pass the new height to the delegate so that is can change the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** cell height with performBatchUpdates
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let height = height as? CGFloat else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.parent.dynamicHeight = height
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(self)
***REMOVED***
***REMOVED***
