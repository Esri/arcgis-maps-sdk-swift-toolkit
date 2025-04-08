// Copyright 2021 Esri
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

/// An example demonstrating how a toolkit component may be used.
struct Example {
    /// The name of the example.
    let name: String
    /// The view for this example.
    var view: AnyView { content() }
    
    /// A closure that builds the view for this example.
    private let content: () -> AnyView
    
    /// Creates an example with the given name and content view.
    /// - Parameters:
    ///   - name: The name for the example.
    ///   - content: The content view for the example.
    init<Content: View>(_ name: String, content: @autoclosure @escaping () -> Content) {
        self.name = name
        self.content = { .init(content()) }
    }
}

extension Example: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Example: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension Example: Identifiable {
    var id: String { name }
}
