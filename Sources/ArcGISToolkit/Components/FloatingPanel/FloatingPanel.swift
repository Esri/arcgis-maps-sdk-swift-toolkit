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

/// A floating panel is a view that overlays a view and supplies view-related
/// content. For a map view, for instance, it could display a legend, bookmarks, search results, etc..
/// Apple Maps, Google Maps, Windows 10, and Collector have floating panel
/// implementations, sometimes referred to as a "bottom sheet".
///
/// Floating panels are non-modal and can be transient, only displaying
/// information for a short period of time like identify results,
/// or persistent, where the information is always displayed, for example a
/// dedicated search panel. They will also be primarily simple containers
/// that clients will fill with their own content.
public struct FloatingPanel<Content>: View where Content: View {
    // Note:  instead of the FloatingPanel being a view, it might be preferable
    // to have it be a view modifier, similar to how SwiftUI doesn't have a
    // SheetView, but a modifier that presents a sheet.
    
    /// The content shown in the floating panel.
    let content: Content
    
    /// Creates a `FloatingPanel`
    /// - Parameter content: The view shown in the floating panel.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State
    private var handleColor: Color = .defaultHandleColor
    
    @State
    private var height: CGFloat?
    
    public var body: some View {
        VStack {
            content
                .frame(minHeight: .minHeight, maxHeight: height)
            Divider()
            Handle(color: handleColor)
                .gesture(drag)
        }
        .esriBorder()
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                handleColor = .activeHandleColor
                // Note:  There is a bug here where `height` can be set
                // larger than the displayed height.  This occurs by continuing
                // to drag down on the handle after the panel reaches it's max
                // height.  When that happens subsequent "drag up" operations
                // don't cause the panel to shrink immediately, but will
                // ultimately snap to the correct height.
                height = max(.minHeight, (height ?? 0) + value.translation.height)
            }
            .onEnded { _ in
                handleColor = .defaultHandleColor
            }
    }
}

private extension CGFloat {
    static let minHeight: CGFloat = 66
}
