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

extension DisclosureGroup {
    /// Adds a marginal amount of trailing padding to the view to keep the right edge of the arrow from
    /// being clipped.
    ///
    /// On Mac Catalyst, DisclosureGroup arrows are on the left and do not have the clipping issue.
    /// - Bug: https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/issues/528
    func disclosureGroupPadding() -> some View {
        modifier(DisclosureGroupPadding())
    }
    
    /// Applies a style to the DisclosureGroup in apps running on Mac Catalyst with the "Optimized
    /// for Mac" interface that keeps the header visually consistent with other platforms.
    @MainActor
    @ViewBuilder
    func disclosureGroupStyleOptimizedForMac() -> some View {
        if UIDevice.current.userInterfaceIdiom == .mac {
            self.disclosureGroupStyle(OptimizedForMac())
        } else {
            self
        }
    }
}

private struct DisclosureGroupPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
#if !targetEnvironment(macCatalyst)
            .padding(.trailing, 2)
#endif
    }
}

/// A style that places the disclosure arrow to the right of the label similar to
/// `AutomaticDisclosureGroupStyle`.
///
/// This is intended for Mac Catalyst apps using the "Optimized for Mac" interface where the
/// disclosure arrow is squished to the left of the content.
private struct OptimizedForMac: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        } label: {
            HStack {
                configuration.label
                Spacer()
                Image(systemName: "chevron.right")
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        if configuration.isExpanded {
            configuration.content
        }
    }
}
