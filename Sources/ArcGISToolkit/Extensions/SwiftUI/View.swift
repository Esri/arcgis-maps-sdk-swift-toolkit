// Copyright 2022 Esri
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

/// A modifier which monitors UIResponder keyboard notifications.
///
/// This modifier makes it easy to monitor state changes of the device keyboard.
struct KeyboardStateChangedModifier: ViewModifier {
    /// The closure to perform when the keyboard state has changed.
    var action: (KeyboardState, CGFloat) -> Void
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) {
                action(.opening, ($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).height)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) {
                action(.open, ($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).height)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                action(.closing, .zero)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                action(.closed, .zero)
            }
    }
}

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
    /// Sets a closure to perform when the keyboard state has changed.
    /// - Parameter action: The closure to perform when the keyboard state has changed.
    @ViewBuilder func onKeyboardStateChanged(_ action: @escaping (KeyboardState, CGFloat) -> Void) -> some View {
        modifier(KeyboardStateChangedModifier(action: action))
    }
    
    /// Adds an equal padding amount to the horizontal edges of this view if the target environment
    /// is Mac Catalyst.
    /// - Parameter length: An amount, given in points, to pad this view on the horizontal edges.
    /// If you set the value to nil, SwiftUI uses a platform-specific default amount.
    /// The default value of this parameter is nil.
    /// - Returns: A view that’s padded by the specified amount on the horizontal edges.
    func catalystPadding(_ length: CGFloat? = nil) -> some View {
        return self
            .padding(isMacCatalyst ? [.horizontal] : [], length)
    }
    
    /// View modifier used to denote the view is selected.
    /// - Parameter isSelected: `true` if the view is selected, `false` otherwise.
    /// - Returns: The modified view.
    func selected(
        _ isSelected: Bool = false
    ) -> some View {
        modifier(SelectedModifier(isSelected: isSelected))
    }
    
    /// Performs the provided action when the view appears after a slight delay.
    /// - Tip: Occasionally delaying allows a sheet's presentation animation to work correctly.
    /// - Parameters:
    ///   - delay: The delay to wait before allow the task to proceed, in nanoseconds. Defaults to 1/4 second.
    ///   - action: The action to perform after the delay.
    func delayedOnAppear(nanoseconds: UInt64 = 250_000_000, action: @MainActor @escaping @Sendable () -> Void) -> some View {
        task { @MainActor in
            try? await Task.sleep(nanoseconds: nanoseconds)
            action()
        }
    }
}

extension View {
    /// Adds an action to perform when this view detects data emitted by the
    /// given async sequence. If `action` is `nil`, then the async sequence is not observed.
    /// The `action` closure is captured the first time the view appears.
    /// - Parameters:
    ///   - sequence: The async sequence to observe.
    ///   - action: The action to perform when a value is emitted by `sequence`.
    ///   The value emitted by `sequence` is passed as a parameter to `action`.
    ///   The `action` is called on the `MainActor`.
    /// - Returns: A view that triggers `action` when `sequence` emits a value.
    @MainActor @ViewBuilder func onReceive<S>(
        _ sequence: S,
        perform action: ((S.Element) -> Void)?
    ) -> some View where S: AsyncSequence, S.Element: Sendable {
        if let action {
            task {
                do {
                    for try await element in sequence {
                        action(element)
                    }
                } catch {}
            }
        } else {
            self
        }
    }
}
