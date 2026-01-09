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

/// A button that is meant to be shown in a top bar for the purpose of dismissing
/// a view.
struct DismissButton: View {
    /// The kind of button, which defines it's purpose.
    enum Kind {
        /// Close the current view. Usually applies to a read-only view
        /// and is usually meant to be shown in the top bar trailing position.
        case close
        /// Cancel the current operation or edits in the view.
        /// This is usually meant to be shown in the top bar leading position.
        case cancel
        /// Confirms the current operation or edits in the view.
        /// This is usually meant to be shown in the top bar trailing position.
        case confirm
        
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
    var dismissAction: (@MainActor () -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    func callDismiss() {
        if let dismissAction {
            dismissAction()
        } else {
            dismiss()
        }
    }
    
    var body: some View {
#if !os(visionOS)
        if #available(iOS 26.0, *) {
            Button(role: kind.role, action: callDismiss)
        } else {
            legacyButton
        }
#else
        legacyButton
#endif
    }
    
    @ViewBuilder var legacyButton: some View {
        Group {
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
