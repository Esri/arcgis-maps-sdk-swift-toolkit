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
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?
    
    /// If `true`, the bookmarks will display as sheet.
    /// If `false`, the bookmarks will display as a popover.
    private var isCompact: Bool {
        return horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    /// Determines if the bookmarks list is currently shown or not.
    @Binding var isPresented: Bool
    
    public var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "bookmark")
            VStack(alignment: .leading) {
                Text("Bookmarks")
                    .font(.headline)
                Text("Select a bookmark")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            if isCompact {
                Spacer()
                Button {
                    isPresented.toggle()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
