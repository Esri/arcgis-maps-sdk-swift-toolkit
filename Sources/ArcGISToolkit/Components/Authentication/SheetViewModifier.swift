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

struct SheetViewModifier<SheetContent: View>: ViewModifier {
    @State private var isPresented = false
    var sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        withAnimation {
            content
                .task { isPresented = true }
                .sheet(isPresented: $isPresented, content: sheetContent)
        }
    }
}

extension View {
    @ViewBuilder
    func sheet<Content: View>(content: @escaping () -> Content) -> some View {
        modifier(SheetViewModifier(sheetContent: content))
    }
}
