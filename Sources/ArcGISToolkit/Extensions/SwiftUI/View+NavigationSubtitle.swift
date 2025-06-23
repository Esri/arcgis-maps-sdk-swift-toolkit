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

struct NavigationSubtitleModifier<S>: ViewModifier where S: StringProtocol {
    let subtitle: S
    
#if swift(>=6.2) && !os(visionOS)
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.navigationSubtitle(subtitle)
        } else {
            content
        }
    }
#elseif targetEnvironment(macCatalyst)
    func body(content: Content) -> some View {
        content.navigationSubtitle(subtitle)
    }
#else
    func body(content: Content) -> some View {
        content
    }
#endif
}

extension View {
    /// Configures the view’s subtitle for purposes of navigation, using a string.
    ///
    /// A view’s navigation subtitle is used to provide additional contextual information alongside the
    /// navigation title. On iOS and iPadOS, the subtitle is displayed with the navigation title in the
    /// navigation bar.
    func _navigationSubtitle<S>(_ subtitle: S) -> some View where S: StringProtocol {
        self.modifier(NavigationSubtitleModifier(subtitle: subtitle))
    }
}
