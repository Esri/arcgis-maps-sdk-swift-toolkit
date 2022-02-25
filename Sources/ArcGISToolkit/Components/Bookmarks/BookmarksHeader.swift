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

/// The header displayed at the top of the bookmarks menu.
struct BookmarksHeader: View {
    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    var isPresented: Bool

    public var body: some View {
        HStack {
            Image(systemName: "bookmark")
            VStack {
                Text("Bookmarks")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Select a bookmark")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle")
            }
        }
        .padding()
    }
}
