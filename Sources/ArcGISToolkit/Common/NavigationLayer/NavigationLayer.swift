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
    let root: () -> Content
    
    @StateObject private var model: NavigationLayerModel
    
    init(_ root: @escaping () -> Content) {
        self.headerTrailing = nil
        self.footer = nil
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    init(_ root: @escaping () -> Content, @ViewBuilder headerTrailing: (@escaping () -> any View)) {
        self.headerTrailing = headerTrailing
        self.footer = nil
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    init(_ root: @escaping () -> Content, @ViewBuilder footer: (@escaping () -> any View)) {
        self.headerTrailing = nil
        self.footer = footer
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    init(_ root: @escaping () -> Content, @ViewBuilder headerTrailing: (@escaping () -> any View), @ViewBuilder footer: (@escaping () -> any View)) {
        self.headerTrailing = headerTrailing
        self.footer = footer
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 0) {
                DestinationHeader(headerTrailing: headerTrailing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Group {
                    if model.views.isEmpty {
                        root()
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
            .environmentObject(model)
            // Apply container width so the animated transitions work correctly.
            .frame(width: geometryProxy.size.width)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    struct SampleList: View {
        @EnvironmentObject private var model: NavigationLayerModel
        
        var body: some View {
            List {
                Button("Present a view") {
                    model.push {
                        Text("View")
                    }
                }
                Button("Present a view with a title") {
                    model.push {
                        Text("View")
                            .navigationLayerTitle("Title")
                    }
                }
                Button("Present a view with a title & subtitle") {
                    model.push {
                        Text("View")
                            .navigationLayerTitle("Title", subtitle: "Subtitle")
                    }
                }
            }
        }
    }
    
    @Previewable @State var isPresented = true
    
    return LinearGradient(
        colors: [.red, .orange, .yellow],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    .ignoresSafeArea(edges: .all)
    .floatingPanel(isPresented: $isPresented) {
        NavigationLayer {
            SampleList()
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
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
