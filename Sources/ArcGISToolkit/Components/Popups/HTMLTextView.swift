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

import WebKit
***REMOVED***

***REMOVED***/ A SwiftUI view to display an HTML string in a `WKWebView`.
@MainActor
struct HTMLTextView: UIViewRepresentable {
***REMOVED******REMOVED***/ The user-defined HTML string.
***REMOVED***let html: String
***REMOVED******REMOVED***/ The height of the view, calculated in the `webView(didFinish:)` delegate method.
***REMOVED***@Binding var height: CGFloat?
***REMOVED***
***REMOVED******REMOVED***/ The HTML string to display, including the header.
***REMOVED***var displayHTML: String {
***REMOVED******REMOVED******REMOVED*** Set the initial scale to 1, don't allow user scaling.
***REMOVED******REMOVED******REMOVED*** This fixes small text with `WKWebView` and also doesn't allow the
***REMOVED******REMOVED******REMOVED*** user to pinch to zoom.
***REMOVED******REMOVED***var header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Inject CSS in a head element to:
***REMOVED******REMOVED******REMOVED*** - word wrap long content such as urls
***REMOVED******REMOVED******REMOVED*** - set font family to default Apple font
***REMOVED******REMOVED******REMOVED*** - set font size to subheadline
***REMOVED******REMOVED******REMOVED*** - remove padding from the body. Add some margin to separate from the
***REMOVED******REMOVED******REMOVED***   border of the webview.
***REMOVED******REMOVED******REMOVED*** - limit images to a maximum width of 100%
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Also wrap the passed HTML fragment inside <html></html>
***REMOVED******REMOVED******REMOVED*** open/close tags so that these CSS styles will apply.
***REMOVED******REMOVED***header = header.appending("""
***REMOVED******REMOVED******REMOVED******REMOVED***<html>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<head>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<style>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***html {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***word-wrap:break-word; font-family:-apple-system; font:-apple-system-subheadline;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***body {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***margin: 10px; 
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***padding:0px;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***background: var(--body-bg);
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: var(--body-color);
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***img {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***max-width: 100%;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***a {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: var(--link-color);
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***</style>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<style type="text/css" media="screen">
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***/* Light mode */
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***:root {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--body-bg: #FFFFFF00;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--body-color: #000000;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--link-color: #0164C8;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***/* Dark mode */
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***@media (prefers-color-scheme: dark) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***:root {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--body-bg: #00000000;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--body-color: #FFFFFF;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***--link-color: #1796FA;
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***</style>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***</head>
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***<body>
***REMOVED******REMOVED******REMOVED******REMOVED***""")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The final string is the header + userHTML + "</body></html>".
***REMOVED******REMOVED***return header
***REMOVED******REMOVED******REMOVED***.appending(html.trimmingCharacters(in: .whitespacesAndNewlines))
***REMOVED******REMOVED******REMOVED***.appending("</body></html>")
***REMOVED***
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> WKWebView {
***REMOVED******REMOVED***let webView = WKWebView()
***REMOVED******REMOVED***webView.isOpaque = false
***REMOVED******REMOVED******REMOVED*** This is a case where we always want the background to be white
***REMOVED******REMOVED******REMOVED*** regardless of light/dark mode. If the user wants to implement dark
***REMOVED******REMOVED******REMOVED*** mode, within their HTML, the background of the HTML will be shown
***REMOVED******REMOVED******REMOVED*** over this background.
***REMOVED******REMOVED***webView.backgroundColor = .clear
***REMOVED******REMOVED***webView.scrollView.backgroundColor = .clear
***REMOVED******REMOVED***webView.scrollView.isScrollEnabled = false
***REMOVED******REMOVED***webView.loadHTMLString(displayHTML, baseURL: nil)
***REMOVED******REMOVED***webView.navigationDelegate = context.coordinator
***REMOVED******REMOVED***return webView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: WKWebView, context: Context) {***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject {
***REMOVED******REMOVED***let onHeightChanged: @MainActor @Sendable (CGFloat) -> Void
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(onHeightChanged: @escaping @MainActor @Sendable (CGFloat) -> Void) {
***REMOVED******REMOVED******REMOVED***self.onHeightChanged = onHeightChanged
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***return Coordinator(
***REMOVED******REMOVED******REMOVED***onHeightChanged: { newHeight in
***REMOVED******REMOVED******REMOVED******REMOVED***guard height == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***height = newHeight
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension HTMLTextView.Coordinator: WKNavigationDelegate {
***REMOVED******REMOVED*** `WKNavigationDelegate` method for navigation actions.
***REMOVED***func webView(
***REMOVED******REMOVED***_ webView: WKWebView,
***REMOVED******REMOVED***decidePolicyFor navigationAction: WKNavigationAction
***REMOVED***) async -> WKNavigationActionPolicy {
***REMOVED******REMOVED***if navigationAction.navigationType == .linkActivated,
***REMOVED******REMOVED***   let url = navigationAction.request.url,
***REMOVED******REMOVED***   (url.isHTTP || url.isHTTPS) {
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(url)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return .cancel
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***return .allow
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** `WKNavigationDelegate` method invoked when a main frame navigation completes. This is
***REMOVED******REMOVED*** where the height calculation happens.
***REMOVED***func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
***REMOVED******REMOVED***Task { @MainActor [onHeightChanged] in
***REMOVED******REMOVED******REMOVED***guard let readyState = try? await webView.evaluateJavaScript("document.readyState") as? String,
***REMOVED******REMOVED******REMOVED******REMOVED***  readyState == "complete" else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let scrollHeight = try? await webView.evaluateJavaScript("document.body.scrollHeight") as? CGFloat else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***onHeightChanged(scrollHeight)
***REMOVED***
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED******REMOVED***/ A Boolean value indicating whether the scheme is HTTP (case-insensitive).
***REMOVED***var isHTTP: Bool {
***REMOVED******REMOVED***scheme?.caseInsensitiveCompare("http") == .orderedSame
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the scheme is HTTPS (case-insensitive).
***REMOVED***var isHTTPS: Bool {
***REMOVED******REMOVED***scheme?.caseInsensitiveCompare("https") == .orderedSame
***REMOVED***
***REMOVED***
