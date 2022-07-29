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
    ///   - isPresented: <#isPresented description#>
    ///   - content: <#content description#>
    /// - Returns: <#description#>
    func floatingPanel<Content>(
        isPresented: Binding<Bool>,
        _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FloatingPanelModifier(
                isPresented: isPresented,
                innerContent: content()
            )
        )
    }
}

/// <#Description#>
private struct FloatingPanelModifier<InnerContent>: ViewModifier where InnerContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    /// <#Description#>
    @Binding var isPresented: Bool
    
    /// <#Description#>
    let innerContent: InnerContent
    
    /// <#Description#>
    /// - Parameter content: <#content description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .trailing) {
                FloatingPanel {
                    innerContent
                }
                .edgesIgnoringSafeArea(.bottom)
                .frame(maxWidth: horizontalSizeClass == .regular ? 360 : .infinity)
            }
    }
}
