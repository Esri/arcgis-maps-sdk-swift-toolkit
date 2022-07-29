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

import SwiftUI

public extension View {
    /// Presents a dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    /// The resulting view allows for interaction with background contents.
    /// - Parameters:
    ///   - detent: <#detent description#>
    ///   - isPresented: <#isPresented description#>
    ///   - maxWidth: <#maxWidth description#>
    ///   - content: <#content description#>
    /// - Returns: <#description#>
    func floatingPanel<Content>(
        backgroundColor: Color = Color(uiColor: .systemBackground),
        detent: Binding<FloatingPanelDetent> = .constant(.half),
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool>,
        maxWidth: CGFloat = 400,
        _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FloatingPanelModifier(
                backgroundColor: backgroundColor,
                detent: detent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                innerContent: content()
            )
        )
    }
}

/// <#Description#>
private struct FloatingPanelModifier<InnerContent>: ViewModifier where InnerContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// A Boolean value indicating whether the environment is compact.
    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    /// <#Description#>
    let backgroundColor: Color
    
    /// <#Description#>
    let detent: Binding<FloatingPanelDetent>
    
    /// <#Description#>
    let horizontalAlignment: HorizontalAlignment
    
    /// <#Description#>
    @Binding var isPresented: Bool
    
    /// <#Description#>
    let maxWidth: CGFloat
    
    /// <#Description#>
    let innerContent: InnerContent
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
                FloatingPanel(
                    backgroundColor: backgroundColor,
                    detent: detent
                ) {
                    innerContent
                }
                .edgesIgnoringSafeArea(.bottom)
                .frame(maxWidth: isCompact ? .infinity : maxWidth)
            }
    }
}
