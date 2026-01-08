// Copyright 2026 Esri
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
    enum Kind {
        case close, cancel, confirm
        
        @available(iOS, introduced: 26.0)
        var role: ButtonRole {
            switch self {
            case .cancel: .cancel
            case .close: .close
            case .confirm: .confirm
            }
        }
        
        var label: String {
            switch self {
            case .cancel: String.cancel
            case .close: String.close
            case .confirm: String.confirm
            }
        }
    }
    let kind: Kind
    
    @Environment(\.dismiss) private var dismiss
    var dismissAction: (@MainActor () -> Void)?
    
    var body: some View {
        let callDismiss = {
            if let dismissAction {
                dismissAction()
            } else {
                dismiss()
            }
        }
        
        Group {
            if #available(iOS 26.0, *) {
                Button(role: kind.role, action: callDismiss)
            } else {
                switch kind {
                case .close, .cancel:
                    Button(
                        kind.label,
                        systemImage: "xmark",
                        action: callDismiss
                    )
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
#if !os(visionOS)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .symbolVariant(.circle.fill)
#endif
                case .confirm:
                    Button(
                        kind.label,
                        systemImage: "checkmark",
                        action: callDismiss
                    )
                }
            }
        }
        .accessibilityLabel(Text(kind.label))
        .labelStyle(.iconOnly)
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DismissButton(kind: .close)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton(kind: .confirm)
                }
            }
            .navigationTitle("Preview")
    }
}
