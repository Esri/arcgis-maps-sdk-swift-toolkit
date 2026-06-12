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

import ArcGIS
import SwiftUI

public extension View {
    func featureEditor(_ feature: Binding<ArcGISFeature?>) -> some View {
        modifier(FeatureEditorModifier(feature: feature))
    }
}

private struct FeatureEditorModifier: ViewModifier {
    @Binding var feature: ArcGISFeature?
    
    /// The inspector's currently presentation selected detent. This is needed to set the default detent to medium.
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    private var isPresented: Binding<Bool> {
        Binding(get: { feature != nil }, set: { _ in feature = nil })
    }
    
    func body(content: Content) -> some View {
        content
            .inspector(isPresented: isPresented) {
                Text("Placeholder")
                    .presentationBackgroundInteraction(.enabled)
                    .presentationContentInteraction(.scrolls)
                    .presentationDetents(
                        [.bar, .medium, .large],
                        selection: $selectedPresentationDetent
                    )
                    .inspectorColumnWidth(ideal: 320)
                    .interactiveDismissDisabled()
            }
    }
}

// MARK: - Bar Detent

/// A custom presentation detent that sizes to the approximate height of a top system toolbar.
private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Implementation was copied from:
        // https://developer.apple.com/documentation/swiftui/custompresentationdetent#overview
        return max(44, context.maxDetentValue * 0.1)
    }
}

private extension PresentationDetent {
    /// A custom presentation detent that sizes to the approximate height of a top system toolbar.
    static let bar = Self.custom(BarDetent.self)
}
