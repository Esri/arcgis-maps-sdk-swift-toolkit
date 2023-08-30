// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A modifier which displays a background and shadow for a view. Used to represent a selected view.
struct SelectedModifier: ViewModifier {
    /// A Boolean value that indicates whether view should display as selected.
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content
                .background(Color.secondary.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(
                    color: .secondary.opacity(0.8),
                    radius: 2
                )
        } else {
            content
        }
    }
}

extension View {
    /// Returns a new `View` that allows a parent `View` to be informed of a child view's size.
    /// - Parameter perform: The closure to be executed when the content size of the receiver
    /// changes.
    /// - Returns: A new `View`.
    func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self, value: geometry.size
                    )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
    
    /// View modifier used to denote the view is selected.
    /// - Parameter isSelected: `true` if the view is selected, `false` otherwise.
    /// - Returns: The modified view.
    func selected(
        _ isSelected: Bool = false
    ) -> some View {
        modifier(SelectedModifier(isSelected: isSelected))
    }
    
    /// Returns a new view with medium presentation detents, if presentation
    /// detents are supported (iOS 16 and up).
    func mediumPresentationDetents() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .presentationDetents([.medium])
        } else {
            return self
        }
    }
    
    /// Performs the provided action when the view appears after a slight delay.
    /// - Tip: Occasionally delaying allows a sheet's presentation animation to work correctly.
    /// - Parameters:
    ///   - delay: The delay to wait before allow the task to proceed, in nanoseconds. Defaults to 1/4 second.
    ///   - action: The action to perform after the delay.
    func delayedOnAppear(nanoseconds: UInt64 = 250_000_000, action: @MainActor @escaping () -> Void) -> some View {
        task { @MainActor in
            try? await Task.sleep(nanoseconds: nanoseconds)
            action()
        }
    }
}
