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

/// A modifier that provides conditional control over when a sheet is used.
struct ConditionalSheetModifier<SheetContent: View>: ViewModifier {
    /// A Boolean value that indicates whether `sheetContent` will be presented or not.
    let isAllowed: Bool
    
    /// Determines when the sheet is presented or not.
    var isPresented: Binding<Bool>
    
    /// Content to be shown in the sheet.
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        if isAllowed {
            content
                .sheet(isPresented: isPresented, content: sheetContent)
        } else {
            content
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
    
    /// - Parameter isAllowed: A Boolean that indicates if this sheet can be shown.
    /// - Returns: Produces a sheet that is only shown if `isAllowed` is set `true`.
    func sheet<SheetContent : View>(
        isAllowed: Bool,
        isPresented: Binding<Bool>,
        content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            ConditionalSheetModifier(
                isAllowed: isAllowed,
                isPresented: isPresented,
                sheetContent: content
            )
        )
    }
}
