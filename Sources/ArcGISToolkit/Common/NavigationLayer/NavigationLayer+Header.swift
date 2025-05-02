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

extension NavigationLayer {
    struct Header: View {
        /// The model for the navigation layer.
        @Environment(NavigationLayerModel.self) private var model
        
        /// The height of the header content.
        @State private var height: CGFloat = .zero
        
        /// The optional closure to perform when the back navigation button is pressed.
        let backNavigationAction: ((NavigationLayerModel) -> Void)?
        
        /// The header trailing content.
        let headerTrailing: (() -> any View)?
        
        /// The width provided to the view.
        let width: CGFloat
        
        var body: some View {
            HStack {
                if backButtonIsVisible {
                    Button {
                        if let backNavigationAction {
                            backNavigationAction(model)
                        } else {
                            model.pop()
                        }
                    } label: {
                        let label = Label {
                            Text("Back")
                        } icon: {
                            Image(systemName: "chevron.left")
                                .font(.title2.weight(.medium))
                        }
                            .padding(5)
                            .contentShape(.rect)
                        if backLabelIsVisible {
                            label
                                .labelStyle(.titleAndIcon)
                        } else {
                            label
                                .labelStyle(.iconOnly)
                        }
                    }
#if targetEnvironment(macCatalyst)
                    .buttonStyle(.plain)
#endif
                    .frame(!backButtonIsVisible, width: width / 6)
                } else if headerTrailing != nil {
                    // There's no back button, but there's header trailing
                    // content, so keep the title centered.
                    Color.clear
                        .frame(width: width / 6, height: 1)
                }
                
                if backButtonIsVisible && !backLabelIsVisible {
                    Divider()
                        .frame(height: height)
                }
                
                if let title = model.title, !title.isEmpty {
                    VStack(alignment: backButtonIsVisible ? .leading : .center) {
                        Text(title)
                            .bold()
                        if let subtitle = model.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(
                        maxWidth: headerTrailing == nil ? .infinity : (width / 6) * 4,
                        alignment: backButtonIsVisible ? .leading : .center
                    )
                    .lineLimit(1)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        height = newValue
                    }
                } else if headerTrailing != nil {
                    // There's no title but there's header trailing content,
                    // so push it to the right.
                    Spacer()
                }
                
                if let headerTrailing {
                    AnyView(headerTrailing())
                        .frame(width: width / 6, alignment: .trailing)
                }
            }
            .padding(headerIsVisible)
            .background(model.headerBackgroundColor)
        }
        
        /// A Boolean value indicating whether the back button is visible, *true* when there is at least one
        /// presented view and *false* otherwise.
        var backButtonIsVisible: Bool {
            model.presented != nil
        }
        
        /// A Boolean value indicating whether the back label is visible, *true* when the back button is
        /// visible and there is no title to show, and *false* otherwise.
        var backLabelIsVisible: Bool {
            backButtonIsVisible && model.title == nil
        }
        
        /// A Boolean value indicating whether any header content is visible.
        var headerIsVisible: Bool {
            backButtonIsVisible || (model.title != nil && !model.title!.isEmpty) || headerTrailing != nil
        }
    }
}

fileprivate extension View {
    /// Optionally positions this view within an invisible frame with the specified size.
    /// - Parameters:
    ///   - applied: A Boolean condition indicating whether padding is applied.
    ///   - width: A fixed width for the resulting view.
    /// - Returns: A view with a fixed width, if applied.
    @ViewBuilder
    func frame(_ applied: Bool, width: CGFloat) -> some View {
        if applied {
            self.frame(width: width, alignment: .leading)
        } else {
            self
        }
    }
    
    /// Optionally adds an equal padding amount to all edges of this view.
    /// - Parameter applied: A Boolean condition indicating whether padding is applied.
    /// - Returns: A view that’s padded, if applied.
    @ViewBuilder
    func padding(_ applied: Bool) -> some View {
        if applied {
            self.padding()
        } else {
            self
        }
    }
}

#Preview("Long title") {
    NavigationLayer { _ in
        Color.clear
            .navigationLayerTitle("Looooooooooooooooooooong title")
    }
}

#Preview("Long subtitle") {
    NavigationLayer { _ in
        Color.clear
            .navigationLayerTitle("Title", subtitle: "Looooooooooooooooooooong subtitle")
    }
}
