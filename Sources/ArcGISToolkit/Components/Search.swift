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
import Combine
import ArcGIS

public struct Search: View {
    public var proxy: Binding<MapViewProxy?>

    @State private var searchText = ""
    
    public init(proxy: Binding<MapViewProxy?>) {
        self.proxy = proxy
    }
    
    public var body: some View {
        ZStack {
            TextField("Search",
                      text: $searchText) { editing in
                print("editing changed")
            } onCommit: { 
                print("On commit")
            }

        }
    }
}
