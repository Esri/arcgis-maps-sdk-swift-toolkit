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

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    init(_ label: String? = nil, action: (() -> Void)? = nil) {
        self.action = action
        self.label = label
    }
    
    let action: (() -> Void)?
    
    let label: String?
    
    var body: some View {
        if let label {
            Button(label) {
                action?() ?? dismiss()
            }
            .buttonStyle(.plain)
            .labelStyle(.titleOnly)
        } else {
            Button("Done", systemImage: "xmark.circle.fill") {
                action?() ?? dismiss()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.hierarchical)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isPresented = true
    LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        .onTapGesture {
            if !isPresented {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            EmptyView()
                .overlay(alignment: .topTrailing) {
                    HStack {
                        DismissButton("Done")
                        DismissButton()
                    }
                    .padding()
                }
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.disabled)
                .presentationDetents([.medium])
        }
        .ignoresSafeArea()
}
