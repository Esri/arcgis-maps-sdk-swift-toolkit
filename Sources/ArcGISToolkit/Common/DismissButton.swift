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
        
        var titleKey: String {
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
        
        if #available(iOS 26.0, *) {
            Button(role: kind.role, action: callDismiss)
        } else {
            switch kind {
            case .close, .cancel:
//                Button(
//                    kind.titleKey,
//                    systemImage: "xmark",
//                    action: callDismiss
//                )
//                //.frame(width: 28, height: 28)
//                .labelStyle(.iconOnly)
//                .symbolRenderingMode(.hierarchical)
//#if !os(visionOS)
//                .buttonStyle(.plain)
//                .foregroundStyle(.secondary)
//                .symbolVariant(.circle.fill)
//#endif
                //                Button(action: callDismiss) {
                //                    Image(systemName: "xmark.circle.fill")
                //                        .resizable()
                //                        .symbolRenderingMode(.hierarchical)
                //                        .foregroundStyle(.secondary)
                //                        .frame(width: 28, height: 28)
                //                }
                //                .buttonStyle(.plain)
                Button(action: callDismiss) {
                    Label {
                        Text(kind.titleKey)
                    } icon: {
                        Image(systemName: "xmark")
                    }

                    Label(kind.titleKey, systemImage: "xmark")
                        
                        .labelStyle(.iconOnly)
                        .symbolRenderingMode(.hierarchical)
#if !os(visionOS)
                        .foregroundStyle(.secondary)
                        .symbolVariant(.circle.fill)
#endif
                }
                .buttonStyle(.plain)

            case .confirm:
                Button(
                    kind.titleKey,
                    systemImage: "checkmark",
                    action: callDismiss
                )
                .labelStyle(.iconOnly)
            }
        }
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
