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

/// The header displayed at the top of the bookmarks menu.
struct BookmarksHeader: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?
    
    /// Determines if the bookmarks list is currently shown or not.
    @Binding var isPresented: Bool
    
    public var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "bookmark")
            VStack(alignment: .leading) {
                Text(
                    "Bookmarks",
                    bundle: .toolkitModule,
                    comment: "A label in reference to bookmarks contained in a map or scene."
                )
                .font(.headline)
                Text(
                    "Select a bookmark",
                    bundle: .toolkitModule,
                    comment: "A label prompting the user to make a selection from the available bookmarks."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            Spacer()
            Button {
                isPresented = false
            } label: {
                Text(String.done)
                    .fontWeight(.semibold)
            }
#if !os(visionOS)
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
#endif
        }
    }
}
