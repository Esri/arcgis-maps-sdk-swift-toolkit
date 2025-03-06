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
    struct DestinationHeader: View {
        @EnvironmentObject private var model: NavigationLayerModel
        
        @State private var size: CGFloat = .zero
        
        /// The header trailing content.
        let headerTrailing: (() -> any View)?
        
        var body: some View {
            HStack(alignment: .top) {
                if showsBack {
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
                    Divider()
                        .frame(height: size)
                }
                if !showsBack {
                    Spacer()
                }
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
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        size = newValue
                    }
                }
                Spacer()
                if let headerTrailing {
                    AnyView(headerTrailing())
                }
            }
            .padding()
        }
        
        var showsBack: Bool {
            !model.views.isEmpty
        }
    }
}
