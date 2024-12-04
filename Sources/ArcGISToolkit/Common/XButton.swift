// Copyright 2024 Esri
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

struct XButton: View {
    enum Context {
        /// The button is used to clear content.
        case clear
        /// The button is used to dismiss content.
        case dismiss
    }
    
    @Environment(\.dismiss) private var dismiss
    
    /// - Parameters:
    ///   - context: The context the button is used in. Helps to provide an accurate accessibility title.
    ///   - action: The button's action. Calls the DismissAction if no action is provided.
    init(_ context: Context, action: (() -> Void)? = nil) {
        self.action = action
        self.context = context
    }
    
    let action: (() -> Void)?
    
    let context: Context
    
    var body: some View {
        Button(title, systemImage: "xmark") {
            action?() ?? dismiss()
        }
        .labelStyle(.iconOnly)
        .symbolRenderingMode(.hierarchical)
#if !os(visionOS)
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .symbolVariant(.circle.fill)
#endif
    }
}

extension XButton {
    /// The title for the button.
    var title: String {
        switch context {
        case .clear:
            String.clear
        case .dismiss:
            String.dismiss
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isPresented = true
    LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay {
            Button {
                isPresented = true
            } label: {
                Text(verbatim: "Present")
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isPresented) {
            EmptyView()
                .overlay(alignment: .topTrailing) {
                    XButton(.dismiss)
                        .padding()
                }
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.disabled)
                .presentationDetents([.medium])
        }
        .ignoresSafeArea()
}
