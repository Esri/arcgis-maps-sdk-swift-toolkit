//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import SwiftUI

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
    ) -> some View where S: AsyncSequence {
        if let action = action {
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
