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

extension Examples {
    enum ListItem {
        case category(_ name: String, examples: [Example])
        case example(Example)
        
        var name: String {
            switch self {
            case .category(let name, _): name
            case .example(let example): example.name
            }
        }
        
        static func example<Content: View>(_ name: String, content: @autoclosure @escaping () -> Content) -> Self {
            return .example(.init(name, content: content()))
        }
    }
}
