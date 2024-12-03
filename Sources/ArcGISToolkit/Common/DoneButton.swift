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

struct DoneButton: View {
    @Environment(\.dismiss) private var dismiss
    
    init(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    let action: (() -> Void)?
    
    var body: some View {
        Button(String.done, systemImage: "xmark.circle.fill") {
            action?() ?? dismiss()
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .labelStyle(.iconOnly)
        .symbolRenderingMode(.hierarchical)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isPresented = true
    LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay(alignment: .center) {
            Button("Present") {
                isPresented = true
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isPresented) {
            EmptyView()
                .overlay(alignment: .topTrailing) {
                    DoneButton()
                        .padding()
                }
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.disabled)
                .presentationDetents([.medium])
        }
        .ignoresSafeArea()
}
