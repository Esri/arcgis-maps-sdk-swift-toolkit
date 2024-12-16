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

struct ExampleList: View {
    /// The name of the list of examples.
    let name: String
    
    /// The list of examples to display.
    var examples: [Example]
    
    var body: some View {
        List(examples, id: \.name) { (example) in
            NavigationLink(example.name, destination: ExampleView(example: example))
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ExampleList: Identifiable {
    nonisolated var id: String { name }
}
