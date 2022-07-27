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
    /// The html string to dispay, including the header.
    var displayHTMLString: String
    
    /// The height of the view, calculated in the `webView(didFinish:)` delegate method.
    @Binding private var dynamicHeight: CGFloat
    
    /// The static header string for displaying html strings in a readable size.
    static var headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header><style>body { font-family:-apple-system; font:-apple-system-subheadline }</style>"
    static var footerString = "</p>"

    /// Creates an `HTMLTextView`.
    /// - Parameters:
    ///   - htmlString: The html string to be displayed.
    ///   - dynamicHeight: A binding to the calculated height of the `WKWebView`.
    init(htmlString: String, dynamicHeight: Binding<CGFloat>) {
        displayHTMLString = HTMLTextView.headerString + htmlString + HTMLTextView.footerString
        _dynamicHeight = dynamicHeight
    }
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.backgroundColor = .clear
        uiView.navigationDelegate = context.coordinator
        uiView.loadHTMLString(displayHTMLString, baseURL: nil)
        uiView.scrollView.isScrollEnabled = false
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLTextView
        
        private var runDidFinishAgain = true

        init(_ parent: HTMLTextView) {
            self.parent = parent
        }
        
        // WKNavigationDelegate method for navigation actions.
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if navigationAction.navigationType == .linkActivated &&
                (navigationAction.request.url?.scheme?.lowercased() == "http" ||
                 navigationAction.request.url?.scheme?.lowercased() == "https") {
                
                if let url = navigationAction.request.url {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
                return .cancel
            }
            else {
                return .allow
            }
        }
        
        // WKNavigationDelegate method where the size calculation happens.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
            self.parent.dynamicHeight = webView.scrollView.contentSize.height
            
            // Sometimes the contentSize has not been updated yet, probably
            // because the view has not been rendered yet. So rerun this again
            // after a delay.  This fixes the issue.
            if runDidFinishAgain {
                runDidFinishAgain = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.webView(webView, didFinish: navigation)
                    self?.runDidFinishAgain = true
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
