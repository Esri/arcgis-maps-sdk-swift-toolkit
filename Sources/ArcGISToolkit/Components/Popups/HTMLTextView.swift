// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import WebKit
import SwiftUI

/// A SwiftUI view to display an HTML string in a `WKWebView`.
@MainActor
struct HTMLTextView: UIViewRepresentable {
    /// The user-defined HTML string.
    let html: String
    /// The height of the view, calculated in the `webView(didFinish:)` delegate method.
    @Binding var height: CGFloat?
    
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
        return header
            .appending(html.trimmingCharacters(in: .whitespacesAndNewlines))
            .appending("</body></html>")
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        // This is a case where we always want the background to be white
        // regardless of light/dark mode. If the user wants to implement dark
        // mode, within their HTML, the background of the HTML will be shown
        // over this background.
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.loadHTMLString(displayHTML, baseURL: nil)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject {
        let onHeightChanged: @MainActor @Sendable (CGFloat) -> Void
        
        init(onHeightChanged: @escaping @MainActor @Sendable (CGFloat) -> Void) {
            self.onHeightChanged = onHeightChanged
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onHeightChanged: { newHeight in
                guard height == nil else { return }
                height = newHeight
            }
        )
    }
}

extension HTMLTextView.Coordinator: WKNavigationDelegate {
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task.detached { @MainActor [onHeightChanged] in
            guard let readyState = try? await webView.evaluateJavaScript("document.readyState") as? String,
                  readyState == "complete" else {
                return
            }
            
            guard let scrollHeight = try? await webView.evaluateJavaScript("document.body.scrollHeight") as? CGFloat else {
                return
            }
            
            onHeightChanged(scrollHeight)
        }
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
