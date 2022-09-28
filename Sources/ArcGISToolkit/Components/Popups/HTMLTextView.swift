// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import WebKit
import SwiftUI

/// A SwiftUI view to display an HTML string in a `WKWebView`.
struct HTMLTextView: UIViewRepresentable {
    /// The user-defined HTML string.
    var userHTML: String = ""
    
    /// The HTML string to display, including the header.
    var displayHTML: String {
        // Set the initial scale to 1, don't allow user scaling.
        // This fixes small text with `WKWebView` and also doesn't allow the
        // user to pinch to zoom.
        var header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        
        // Inject CSS in a head element to:
        // - word wrap long content such as urls
        // - set font family to default Apple font
        // - set font size to subheadline
        // - remove padding from the body. Add some margin to separate from the
        //   border of the webview.
        // - limit images to a maximum width of 100%
        //
        // Also wrap the passed HTML fragment inside <html></html>
        // open/close tags so that these CSS styles will apply.
        header = header.appending("""
                <html>
                    <head>
                        <style>
                            html {
                                word-wrap:break-word; font-family:-apple-system; font:-apple-system-subheadline;
                            }
                            body {
                                margin: 10px; 
                                padding:0px;
                                background: var(--body-bg);
                                color: var(--body-color);
                            }
                            img {
                                max-width: 100%;
                            }
                            a {
                                color: var(--link-color);
                            }
                        </style>
                        <style type="text/css" media="screen">
                            /* Light mode */
                            :root {
                                --body-bg: #FFFFFF00;
                                --body-color: #000000;
                                --link-color: #0164C8;
                            }
                            
                            /* Dark mode */
                            @media (prefers-color-scheme: dark) {
                                :root {
                                    --body-bg: #00000000;
                                    --body-color: #FFFFFF;
                                    --link-color: #1796FA;
                                }
                            }
                        </style>
                    </head>
                    <body>
                """)
        
        // The final string is the header + userHTML + "</body></html>".
        return header.appending(
            userHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        ).appending("</body></html>")
    }
    
    /// The height of the view, calculated in the `webView(didFinish:)` delegate method.
    @Binding private var height: CGFloat
    
    /// Creates an `HTMLTextView`.
    /// - Parameters:
    ///   - html: The HTML string to be displayed.
    ///   - height: A binding to the calculated height of the `WKWebView`.
    init(html: String, height: Binding<CGFloat>) {
        userHTML = html
        _height = height
    }
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.isOpaque = false
        // This is a case where we always want the background to be white
        // regardless of light/dark mode. If the user wants to implement dark
        // mode, within their HTML, the background of the HTML will be shown
        // over this background.
        uiView.backgroundColor = .clear
        uiView.scrollView.backgroundColor = .clear
        uiView.scrollView.isScrollEnabled = false
        uiView.loadHTMLString(displayHTML, baseURL: nil)
        uiView.navigationDelegate = context.coordinator
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLTextView
        
        /// A Boolean value indicating whether the content started arriving for the main frame.
        private var hasCommitted = false
        
        /// A Boolean value indicating whether the height is calculated for the web view.
        private var hasHeight = false
        
        init(_ parent: HTMLTextView) {
            self.parent = parent
        }
        
        // `WKNavigationDelegate` method invoked when content starts arriving for the main frame.
        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            hasCommitted = true
        }
        
        // `WKNavigationDelegate` method for navigation actions.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               (url.isHTTP || url.isHTTPS) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
                return .cancel
            }
            else {
                return .allow
            }
        }
        
        // `WKNavigationDelegate` method invoked when a main frame navigation completes. This is
        // where the height calculation happens.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            webView.evaluateJavaScript("document.readyState") { [weak self] complete, _ in
                guard complete != nil,
                      self?.hasCommitted ?? false
                else { return }
                
                webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
                    guard let self = self else { return }
                    guard let height = height as? CGFloat,
                          !self.hasHeight else {
                        return
                    }
                    // Set the new height, if we have one.
                    self.parent.height = height
                    
                    // With certain HTML strings, the JavaScript above kept
                    // getting called, with increasingly large heights. This
                    // prevents that from happening. As this block is only
                    // called after the `document.readyState` is "complete",
                    // this should be OK.
                    self.hasHeight = true
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

private extension URL {
    /// A Boolean value indicating whether the scheme is HTTP (case-insensitive).
    var isHTTP: Bool {
        scheme?.caseInsensitiveCompare("http") == .orderedSame
    }
    
    /// A Boolean value indicating whether the scheme is HTTPS (case-insensitive).
    var isHTTPS: Bool {
        scheme?.caseInsensitiveCompare("https") == .orderedSame
    }
}
