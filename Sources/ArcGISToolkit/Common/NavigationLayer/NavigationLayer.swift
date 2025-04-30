// Copyright 2025 Esri
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

/// Navigation designed to work for components hosted in Floating Panels.
///
/// As of iOS 18, nested Navigation Stacks aren't supported. Because we don't know how a developer has
/// presented a Toolkit component, NavigationLayer provides a simple navigation implementation that can be
/// used in a component presented either modally (e.g. a Sheet) or non-modally (a Floating Panel).
struct NavigationLayer<Content: View>: View {
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// The header trailing content.
    let headerTrailing: (() -> any View)?
    
    /// The footer content.
    let footer: (() -> any View)?
    
    /// The root view.
    let root: (NavigationLayerModel) -> Content
    
    /// The optional closure to perform when the back navigation button is pressed.
    var backNavigationAction: ((NavigationLayerModel) -> Void)? = nil
    
    /// The closure to perform when model's path changes.
    var onNavigationChangedAction: ((NavigationLayerModel.Item?) -> Void)?
    
    /// The model for the navigation layer.
    @State private var model = NavigationLayerModel()
    
    init(_ root: @escaping (NavigationLayerModel) -> Content) {
        self.headerTrailing = nil
        self.footer = nil
        self.root = root
    }
    
    init(_ root: @escaping (NavigationLayerModel) -> Content, headerTrailing: (@escaping () -> any View)) {
        self.headerTrailing = headerTrailing
        self.footer = nil
        self.root = root
    }
    
    init(_ root: @escaping (NavigationLayerModel) -> Content, footer: (@escaping () -> any View)) {
        self.headerTrailing = nil
        self.footer = footer
        self.root = root
    }
    
    init(_ root: @escaping (NavigationLayerModel) -> Content, headerTrailing: (@escaping () -> any View), footer: (@escaping () -> any View)) {
        self.headerTrailing = headerTrailing
        self.footer = footer
        self.root = root
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 0) {
                Header(
                    backNavigationAction: backNavigationAction,
                    headerTrailing: headerTrailing,
                    width: geometryProxy.size.width
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                Group {
                    if model.views.isEmpty {
                        root(model)
                            .transition(model.transition)
                    } else if let presented = model.presented?.view {
                        AnyView(presented())
                            // Re-trigger the transition animation when view count changes.
                            .id(model.views.count)
                            .transition(model.transition)
                    }
                }
                .onPreferenceChange(NavigationLayerTitle.self) { title in
                    Task { @MainActor in
                        self.model.title = title
                    }
                }
                .onPreferenceChange(NavigationLayerSubtitle.self) { subtitle in
                    Task { @MainActor in
                        self.model.subtitle = subtitle
                    }
                }
                if let footer {
                    AnyView(footer())
                        .padding()
                        .padding([.bottom], isPortraitOrientation ? nil : .zero)
                        .overlay(Divider(), alignment: .top)
                        .transition(.move(edge: .bottom))
                }
            }
            .environment(model)
            // Apply container width so the animated transitions work correctly.
            .frame(width: geometryProxy.size.width)
            .onChange(of: model.views.count) {
                onNavigationChangedAction?(model.presented ?? nil)
            }
        }
    }
}

struct PreviewList: View {
    @Environment(NavigationLayerModel.self) private var model
    
    var body: some View {
        List {
            Button("Present a view") {
                model.push {
                    PreviewList()
                }
            }
            
            Button("Present a view with a title") {
                model.push {
                    PreviewList()
                        .navigationLayerTitle("Title")
                }
            }
            
            Button("Present a view with a title and subtitle") {
                model.push {
                    PreviewList()
                        .navigationLayerTitle("Title", subtitle: "Subtitle")
                }
            }
        }
        .navigationLayerTitle("Title", subtitle: "Subtitle")
    }
}

#Preview("init(_:)") {
    NavigationLayer { _ in
        PreviewList()
    }
}

#Preview("init(_:headerTrailing:)") {
    NavigationLayer { _ in
        PreviewList()
    } headerTrailing: {
        Button { } label: { Image(systemName: "xmark")  }
    }
}

#Preview("init(_:footer:)") {
    NavigationLayer { _ in
        PreviewList()
    } footer: {
        Text(verbatim: "Footer")
    }
}

#Preview("init(_:headerTrailing:footer:)") {
    NavigationLayer { _ in
        PreviewList()
    } headerTrailing: {
        Button { } label: { Image(systemName: "xmark")  }
    } footer: {
        Text(verbatim: "Footer")
    }
}

extension NavigationLayer {
    /// Sets a closure to perform when the back navigation button is pressed.
    /// - Parameter action: The closure to perform when the back navigation button is pressed.
    /// - Note: Use this to interrupt reverse navigation (e.g. to warn a user of unsaved edits). The closure
    /// provides a reference to the navigation layer module which can be used to trigger the reverse
    /// navigation when ready.
    func backNavigationAction(perform action: @escaping (NavigationLayerModel) -> Void) -> Self {
        var copy = self
        copy.backNavigationAction = action
        return copy
    }
    
    /// Sets a closure to perform when the navigation layer's path changed.
    /// - Parameter action: The closure to perform when the navigation layer's path changed
    /// - Note: If no item is provided, the root view is presented..
    func onNavigationPathChanged(perform action: @escaping (NavigationLayerModel.Item?) -> Void) -> Self {
        var copy = self
        copy.onNavigationChangedAction = action
        return copy
    }
}

struct NavigationLayerTitle: PreferenceKey {
    static let defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

struct NavigationLayerSubtitle: PreferenceKey {
    static let defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

extension View {
    /// Sets a title for the navigation layer destination.
    /// - Parameters:
    ///   - title: The title for the navigation layer destination.
    func navigationLayerTitle(_ title: String) -> some View {
        preference(key: NavigationLayerTitle.self, value: title)
    }
    
    /// Sets a title and subtitle for the navigation layer destination.
    /// - Parameters:
    ///   - title: The title for the navigation layer destination.
    ///   - subtitle: The subtitle for the navigation layer destination.
    func navigationLayerTitle(_ title: String, subtitle: String) -> some View {
        preference(key: NavigationLayerTitle.self, value: title)
            .preference(key: NavigationLayerSubtitle.self, value: subtitle)
    }
}
