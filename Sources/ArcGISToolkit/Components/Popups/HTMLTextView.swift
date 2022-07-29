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
    
    /// The html string to dispay, including the header.
    var displayHTML: String {
        // Set the initial scale to 1, don't allow user scaling.
        // When we went to WKWebView from UIWebView, the content got smaller,
        // this fixes that and also doesn't allow the user to pinch to zoom.
        var header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        
        // Inject css in a head element to:
        // - word wrap long content such as urls
        // - set font family to default apple font
        // - set font size to subheadline
        // - remove padding from the body. Add some margin to separate from the border of the webview.
        // - limit images to a maximum width of 100%
        //
        // Also wrap the passed html fragment inside <html></html>
        // open/close tags so that these css styles will apply
        //
        // In order to make hyperlinks match our
        // app tint we need to be passed a color
        // and to dynamically inject it into the
        // HTML/CSS
        //
        header = header.appending("""
                <html>
                    <head>
                        <style>
                            html {
                                word-wrap:break-word; font-family:-apple-system; font:-apple-system-subheadline;
                            }
                            body {
                                margin:10px; padding:0px;
                            }
                            img {
                                max-width: 100%;
                            }
                        </style>
                    </head>
                    <body>
                """)
        
        // The final string is the header + userHTML + closing
        return header.appending(userHTML.trimmingCharacters(in: .whitespacesAndNewlines)).appending("</body></html>")
    }
    
    /// The height of the view, calculated in the `webView(didFinish:)` delegate method.
    @Binding private var dynamicHeight: CGFloat

    /// Creates an `HTMLTextView`.
    /// - Parameters:
    ///   - html: The html string to be displayed.
    ///   - dynamicHeight: A binding to the calculated height of the `WKWebView`.
    init(html: String, dynamicHeight: Binding<CGFloat>) {
        userHTML = html
        _dynamicHeight = dynamicHeight
    }
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.isOpaque = false
        // This is a case where we always want the background to be white regardless of light/dark mode. If the user wants to implement dark mode,
        // within their HTML, the background of the HTML will be shown over this background.
        uiView.backgroundColor = .white
        uiView.scrollView.backgroundColor = .white
        uiView.scrollView.isScrollEnabled = false
        uiView.loadHTMLString(displayHTML, baseURL: nil)
        uiView.navigationDelegate = context.coordinator
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLTextView
        
        private var hasCommitted = false

        init(_ parent: HTMLTextView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            hasCommitted = true
        }
        
        // WKNavigationDelegate method for navigation actions.
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated,
               (navigationAction.request.url?.scheme?.lowercased() == "http" ||
                navigationAction.request.url?.scheme?.lowercased() == "https"),
               let url = navigationAction.request.url {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
                return .cancel
            }
            else {
                return .allow
            }
        }
        
        // WKNavigationDelegate method where the size calculation happens.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            webView.evaluateJavaScript("document.readyState") { [weak self] complete, _ in
                guard complete != nil, let webView = webView  else {
                    return
                }
                webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
                    // Pass the new height to the delegate so that is can change the
                    // cell height with performBatchUpdates
                    //
                    guard let height = height as? CGFloat else {
                        return
                    }
                    self?.parent.dynamicHeight = height
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
