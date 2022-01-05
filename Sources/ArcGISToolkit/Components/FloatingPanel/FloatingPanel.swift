// Copyright 2021 Esri.

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
/// Floating Panels are non-modal and can be transient, only displaying
/// information for a short period of time like identify results,
/// or persistent, where the information is always displayed, for example a
/// dedicated search panel. They will also be primarily simple containers
/// that clients will fill with their own content.
public struct FloatingPanel<Content> : View where Content : View {
    /// The content that is to be housed in the floating panel.
    let content: Content
    
    /// Creates a `FloatingPanel`
    /// - Parameter content: The view shown in the floating panel.
    public init(content: Content) {
        self.content = content
    }
    
    @State
    private var handleColor: Color = defaultHandleColor

    @State
    private var height: CGFloat? = nil
    
    private let minHeight: CGFloat = 66
    
    public var body: some View {
        VStack {
            VStack {
                content
                    .frame(minHeight: minHeight, maxHeight: height)
                Handle(color: handleColor)
                    .gesture(drag)
            }
            .esriBorder()
            Spacer()
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.handleColor = Self.activeHandleColor
                height = max(minHeight, (height ?? 0) + value.translation.height)
            }
            .onEnded { _ in
                self.handleColor = Self.defaultHandleColor
            }
    }
}

private extension FloatingPanel {
    static var defaultHandleColor: Color { .secondary }
    static var activeHandleColor: Color { .primary }
}

private struct Handle: View {
    var color: Color
    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: 100, height: 8.0)
            .cornerRadius(4.0)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
    }
}
