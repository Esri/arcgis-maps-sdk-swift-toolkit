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
        @EnvironmentObject private var model: NavigationLayerModel
        
        @State private var height: CGFloat = .zero
        
        let width: CGFloat
        
        /// The header trailing content.
        let headerTrailing: (() -> any View)?
        
        var body: some View {
            HStack(alignment: .top) {
                Group {
                    Button {
                        model.pop()
                    } label: {
                        let label = Label("Back", systemImage: "chevron.left")
                        if model.title == nil {
                            label
                                .labelStyle(.titleAndIcon)
                        } else {
                            label
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                .opacity(showsBack ? 1 : .zero)
                .frame(!showsBack, width: width / 6)
                if showsBack {
                    Divider()
                        .frame(height: height)
                }
                if !showsBack {
                    Spacer()
                }
                Group {
                    if let title = model.title, !title.isEmpty {
                        VStack(alignment: showsBack ? .leading : .center) {
                            Text(title)
                                .bold()
                            if let subtitle = model.subtitle, !subtitle.isEmpty  {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .lineLimit(1)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { newValue in
                            height = newValue
                        }
                    }
                }
                .frame(maxWidth: (width / 6) * 4, alignment: showsBack ? .leading : .center)
                Spacer()
                if let headerTrailing {
                    AnyView(headerTrailing())
                        .frame(width: width / 6, alignment: .trailing)
                }
            }
            .padding(showsBack || (model.title != nil && !model.title!.isEmpty))
        }
        
        var showsBack: Bool {
            !model.views.isEmpty
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func frame(_ applied: Bool, width: CGFloat) -> some View {
        if applied {
            self.frame(width: width, alignment: .leading)
        } else {
            self
        }
    }
    /// Optionally adds an equal padding amount to specific edges of this view.
    /// - Parameter applied: A Boolean condition indicating whether padding is applied.
    /// - Returns: A view that’s padded if specified.
    @ViewBuilder
    func padding(_ applied: Bool) -> some View {
        if applied {
            self.padding()
        } else {
            self
        }
    }
}
