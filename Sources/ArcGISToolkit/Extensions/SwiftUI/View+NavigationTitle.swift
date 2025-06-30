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

/// A view modifier that populates the toolbar with a custom navigation title and subtitle.
private struct NavigationTitleModifier<T, S>: ViewModifier where T: StringProtocol, S: StringProtocol {
    /// The string to display as the title.
    let title: T
    
    /// The string to display as the subtitle.
    let subtitle: S
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title)
                            .fontWeight(.semibold)
                        
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    /// Configures the view’s title and subtitle for purposes of navigation.
    /// - Parameters:
    ///   - title: The string to display as the title.
    ///   - subtitle: The string to display as the subtitle.
    ///
    /// A view’s navigation subtitle is used to provide additional contextual information alongside
    /// the navigation title. On iOS and iPadOS, the subtitle is displayed with the navigation title
    /// in the navigation bar.
    ///
    /// - Note: This modifier allows displaying a navigation subtitle on platforms where
    /// `View.navigationSubtitle(_:)` is not supported. `View.navigationTitle(_:)`
    /// should be used instead when a subtitle is not required.
    @ViewBuilder
    func navigationTitle<T, S>(
        _ title: T,
        subtitle: S
    )-> some View where T: StringProtocol, S: StringProtocol {
#if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26.0, *) {
            self.navigationTitle(title)
                .navigationSubtitle(subtitle)
        } else {
            self.modifier(NavigationTitleModifier(title: title, subtitle: subtitle))
        }
#elseif targetEnvironment(macCatalyst)
        self.navigationTitle(title)
            .navigationSubtitle(subtitle)
#else
        self.modifier(NavigationTitleModifier(title: title, subtitle: subtitle))
#endif
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .navigationTitle("Title", subtitle: "Subtitle")
    }
}
