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
        
        var body: some View {
            HStack {
                Button {
                    model.pop()
                } label: {
                    let label = Label("Back", systemImage: "chevron.left")
                    if model.presented?.title == nil {
                        label
                            .labelStyle(.titleAndIcon)
                    } else {
                        label
                            .labelStyle(.iconOnly)
                    }
                }
                if let title = model.presented?.title {
                    Divider()
                        .frame(height: size)
                    VStack(alignment: .leading) {
                        Text(title)
                            .bold()
                        if let subtitle = model.presented?.subtitle {
                            Text(subtitle)
                                .font(.caption)
                        }
                    }
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        size = newValue
                    }
                }
            }
        }
    }
}
