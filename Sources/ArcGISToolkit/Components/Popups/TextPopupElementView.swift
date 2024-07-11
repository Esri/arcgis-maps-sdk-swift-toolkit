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

import SwiftUI
import ArcGIS

/// A view displaying a `TextPopupElement`.
struct TextPopupElementView: View {
    /// The `PopupElement` to display.
    let popupElement: TextPopupElement
    
    /// The calculated height of the `HTMLTextView`.
    @State private var webViewHeight: CGFloat?
    
    var body: some View {
        if !popupElement.text.isEmpty {
            ZStack {
                HTMLTextView(html: popupElement.text, height: $webViewHeight)
                    .frame(height: webViewHeight ?? .zero)
                if webViewHeight == .zero {
                    // Show `ProgressView` until `HTMLTextView` has set the height.
                    ProgressView()
                }
            }
        }
    }
}
