// Copyright 2023 Esri.

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

struct Tests: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Basemap Gallery Tests", destination: BasemapGalleryTestView())
                NavigationLink("Bookmarks Tests", destination: BookmarksTestView())
                NavigationLink("Floor Filter Tests", destination: FloorFilterTestView())
                NavigationLink("Form View Tests", destination: FormViewTestView())
            }
        }
        .navigationViewStyle(.stack)
    }
}
