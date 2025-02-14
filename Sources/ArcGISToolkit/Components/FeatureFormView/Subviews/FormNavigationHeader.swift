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

/// <#Description#>
struct FormNavigationHeader: ViewModifier {
    /// <#Description#>
    @Binding var path: NavigationPath
    
    @Environment(\.associationChangeRequestedAction) var associationChangeRequestedAction: ((() -> Void) -> Void)?
    
    /// <#Description#>
    let subtitle: String?
    
    /// <#Description#>
    let title: String
    
    /// <#Description#>
    let visibility: Visibility
    
    func body(content: Content) -> some View {
        content 
            .navigationBarBackButtonHidden()
            .toolbar {
                if visibility != .hidden {
                    ToolbarItem(placement: .navigation) {
                        HStack {
                            if !path.isEmpty {
                                Button {
                                    associationChangeRequestedAction?({
                                        path.removeLast()
                                    })
                                } label: {
                                    // Label(:systemImage:) does not work properly
                                    // here so we use an Image only.
                                    Image(systemName: "chevron.left")
                                }
                                Divider()
                            }
                            VStack(alignment: .leading) {
                                if let subtitle {
                                    VStack(alignment: .leading) {
                                        Text(title)
                                            .bold()
                                        Text(subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Text(title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func formNavigationHeader(
        path: Binding<NavigationPath>,
        visibility: Visibility,
        title: String,
        subtitle: String? = nil
    ) -> some View {
        modifier(
            FormNavigationHeader(
                path: path,
                subtitle: subtitle,
                title: title,
                visibility: visibility
            )
        )
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        List(1..<4) {
            NavigationLink($0.formatted(), value: $0)
        }
        .formNavigationHeader(path: $path, visibility: .visible, title: "Numbers")
        .navigationDestination(for: Int.self) {
            Text($0.formatted())
                .formNavigationHeader(path: $path, visibility: .visible, title: "Number \($0)", subtitle: "Details")
        }
    }
}
