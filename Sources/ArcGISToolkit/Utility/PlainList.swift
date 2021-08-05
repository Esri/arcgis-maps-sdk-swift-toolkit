// Copyright 2021 Esri.

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

/// A List with the `.plain` list style.
public struct PlainList<Content> : View where Content : View {
    let content: Content
    /// Creates a plain list with the given content.
    /// - Parameters:
    ///   - content: The content of the list.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    /// The content of the list.
    public var body: some View {
        List {
            content
        }
        .listStyle(.plain)
    }
}
