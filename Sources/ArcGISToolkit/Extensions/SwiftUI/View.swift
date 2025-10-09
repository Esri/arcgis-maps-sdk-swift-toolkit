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
    
    /// Sets the tint within this view to override system styling.
    ///
    /// As of iOS 16, certain elements within Inspectors are grayed out. This happens in compact-width
    /// environments at the large presentation detent. Use this modifier to override the gray system coloring.
    /// - Important: Using `Color.accentColor` was found to not work, so static colors, like blue,
    /// are recommended instead.
    /// - Note: The tint is only respected on iOS and not on Catalyst or visionOS.
    /// - SeeAlso: Apollo #1308
    func inspectorTint<S>(_ tint: S) -> some View where S: ShapeStyle {
        self.tint(tint)
    }
    
    /// Configures whether navigation links show a disclosure indicator.
    ///
    /// - Bug: The `navigationLinkIndicatorVisibility` symbol will crash apps at launch on
    /// iOS 18 when built with Xcode 26.0 & 26.0.1. (FB20596543) 
    @ViewBuilder func _navigationLinkIndicatorVisibility(_ visibility: Visibility) -> some View {
#if compiler(>=6.2.1.4.2) // (Xcode 26.1 Beta 2)
        self
            .navigationLinkIndicatorVisibility(visibility)
#else
        self
#endif
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
