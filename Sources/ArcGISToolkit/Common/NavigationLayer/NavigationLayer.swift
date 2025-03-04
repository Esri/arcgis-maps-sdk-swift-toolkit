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
    
    let root: () -> Content
    
    @StateObject private var model: NavigationLayerModel
    
    init(_ root: @escaping () -> Content) {
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 0) {
                if model.views.isEmpty {
                    root()
                        .transition(model.transition)
                } else if let presented = model.presented?.view {
                    VStack {
                        DestinationHeader()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Spacer()
                        AnyView(presented())
                        Spacer()
                    }
                    // Re-trigger the transition animation when view count changes.
                    .id(model.views.count)
                    .transition(model.transition)
                }
                if let footerContent = model.footerContent {
                    AnyView(footerContent())
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
                    model.push { Text("View") }
                }
                Button("Present a view with a title") {
                    model.push(title: "Title") { Text("View") }
                }
                Button("Present a view with a title & subtitle") {
                    model.push(title: "Title", subtitle: "Subtitle") { Text("View") }
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

struct NavigationLayerFooterContent: ViewModifier {
    @EnvironmentObject var model: NavigationLayerModel
    
    let id: UUID
    
    let footerContent: () -> (any View)
    
    func body(content: Content) -> some View {
#warning("onChange(of: UUID) action tried to update multiple times per frame.")
        content
            .task(id: id) {
                withAnimation {
                    model.footerContent = footerContent
                }
            }
    }
}

extension View {
    func navigationLayerFooter(
        id: UUID = UUID(),
        @ViewBuilder _ view: @escaping () -> (any View)
    ) -> some View {
        modifier(NavigationLayerFooterContent(id: id, footerContent: view))
    }
}
