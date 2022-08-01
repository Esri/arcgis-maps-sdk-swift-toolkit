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
***REMOVED******REMOVED***/ The HTML string to dispay, including the header.
***REMOVED***var displayHTML: String {
***REMOVED******REMOVED******REMOVED*** Set the initial scale to 1, don't allow user scaling.
***REMOVED******REMOVED******REMOVED*** This fixess small text with `WKWebView` and also doesn't allow the
***REMOVED******REMOVED******REMOVED*** user to pinch to zoom.
***REMOVED******REMOVED***var header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Inject CSS in a head element to:
***REMOVED******REMOVED******REMOVED*** - word wrap long content such as urls
***REMOVED******REMOVED******REMOVED*** - set font family to default apple font
***REMOVED******REMOVED******REMOVED*** - set font size to subheadline
***REMOVED******REMOVED******REMOVED*** - remove padding from the body. Add some margin to separate from the
***REMOVED******REMOVED******REMOVED***   border of the webview.
***REMOVED******REMOVED******REMOVED*** - limit images to a maximum width of 100%
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Also wrap the passed HTML fragment inside <html></html>
***REMOVED******REMOVED******REMOVED*** open/close tags so that these CSS styles will apply
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
***REMOVED******REMOVED******REMOVED*** The final string is the header + userHTML + "</body></html>"
***REMOVED******REMOVED***return header.appending(
***REMOVED******REMOVED******REMOVED***userHTML.trimmingCharacters(in: .whitespacesAndNewlines)
***REMOVED******REMOVED***).appending("</body></html>")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The height of the view, calculated in the `webView(didFinish:)` delegate method.
***REMOVED***@Binding private var height: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ Creates an `HTMLTextView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - html: The HTML string to be displayed.
***REMOVED******REMOVED***/   - height: A binding to the calculated height of the `WKWebView`.
***REMOVED***init(html: String, height: Binding<CGFloat>) {
***REMOVED******REMOVED***userHTML = html
***REMOVED******REMOVED***_height = height
***REMOVED***
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> WKWebView {
***REMOVED******REMOVED***WKWebView()
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: WKWebView, context: Context) {
***REMOVED******REMOVED***uiView.isOpaque = false
***REMOVED******REMOVED******REMOVED*** This is a case where we always want the background to be white
***REMOVED******REMOVED******REMOVED*** regardless of light/dark mode. If the user wants to implement dark
***REMOVED******REMOVED******REMOVED*** mode, within their HTML, the background of the HTML will be shown
***REMOVED******REMOVED******REMOVED*** over this background.
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
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the content started arriving for the main frame.
***REMOVED******REMOVED***private var hasCommitted = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the height is calculated for the web view.
***REMOVED******REMOVED***private var hasHeight = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(_ parent: HTMLTextView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** `WKNavigationDelegate` method invoked when content starts arriving for the main frame.
***REMOVED******REMOVED***public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
***REMOVED******REMOVED******REMOVED***hasCommitted = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** `WKNavigationDelegate` method for navigation actions.
***REMOVED******REMOVED***func webView(
***REMOVED******REMOVED******REMOVED***_ webView: WKWebView,
***REMOVED******REMOVED******REMOVED***decidePolicyFor navigationAction: WKNavigationAction
***REMOVED******REMOVED***) async -> WKNavigationActionPolicy {
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
***REMOVED******REMOVED******REMOVED*** `WKNavigationDelegate` method invoked when a main frame navigation completes. This is
***REMOVED******REMOVED******REMOVED*** where the height calculation happens.
***REMOVED******REMOVED***func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
***REMOVED******REMOVED******REMOVED***webView.evaluateJavaScript("document.readyState") { [weak self] complete, _ in
***REMOVED******REMOVED******REMOVED******REMOVED***guard complete != nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  self?.hasCommitted ?? false
***REMOVED******REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let height = height as? CGFloat,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  !self.hasHeight else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the new height, if we have one.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.parent.height = height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** With certain HTML strings, the JavaScript above kept
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** getting called, with increasingly large heights. This
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** prevents that from happening. As this block is only
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** called after the `document.readyState` is "complete",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** this should be OK.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.hasHeight = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(self)
***REMOVED***
***REMOVED***
