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

public struct FeatureFormViewReader<Content: View>: View {
    /// The view builder that creates the reader's content.
    public var content: (FeatureFormViewProxy) -> Content
    
    /// The proxy of this reader.
    @State private var proxy = FeatureFormViewProxy()
    
    /// Creates an instance that can perform programmatic actions of its
    /// child ``FeatureFormView``.
    /// - Parameter content: The reader's content, containing one map view. This
    /// view builder receives a ``FeatureFormViewProxy`` instance that you use to
    /// perform actions on the ``FeatureFormView``.
    public init(@ViewBuilder content: @escaping (FeatureFormViewProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack { content(proxy) }
            .onPreferenceChangeMain(PreferredFeatureFormViewKey.self) { featureFormView in
                proxy.featureFormView = featureFormView
            }
    }
}

extension FeatureFormView: @preconcurrency Equatable {
    public static func == (lhs: FeatureFormView, rhs: FeatureFormView) -> Bool {
        lhs.featureForm.feature == rhs.featureForm.feature
    }
}

struct PreferredFeatureFormViewKey: PreferenceKey {
    static func reduce(value: inout FeatureFormView?, nextValue: () -> FeatureFormView?) {
        if value == nil, let nextValue = nextValue() {
            value = nextValue
        }
    }
}

extension View {
    nonisolated func onPreferenceChangeMain<K>(
        _ key: K.Type = K.self,
        perform action: @escaping @MainActor (K.Value) -> Void
    ) -> some View where K: PreferenceKey, K.Value: Equatable & Sendable {
        return onPreferenceChange(key) { newValue in
            if Thread.isMainThread {
                MainActor.assumeIsolated {
                    action(newValue)
                }
            } else {
                Task { @MainActor in
                    action(newValue)
                }
            }
        }
    }
}
