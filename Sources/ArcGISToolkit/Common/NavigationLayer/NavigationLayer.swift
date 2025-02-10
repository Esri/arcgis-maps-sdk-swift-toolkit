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
    let root: () -> Content
    
    @State private var width: CGFloat = .zero
    
    @StateObject private var model: NavigationLayerModel
    
    init(_ root: @escaping () -> Content) {
        self.root = root
        _model = StateObject(wrappedValue: NavigationLayerModel())
    }
    
    var body: some View {
        Group {
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
        }
        .environmentObject(model)
        // Apply container width so the animated transitions work correctly.
        .frame(width: width)
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            width = newValue
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    struct SampleList: View {
        @EnvironmentObject private var model: NavigationLayerModel
        
        var body: some View {
            List {
                Button("Present a simple view") {
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
    .sheet(isPresented: $isPresented) {
        NavigationLayer {
            SampleList()
        }
        .interactiveDismissDisabled()
        .presentationDetents([.medium])
    }
}
