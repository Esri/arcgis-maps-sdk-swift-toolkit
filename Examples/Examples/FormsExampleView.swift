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

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FormsExampleView: View {
    @State private var isPresented = true
    
    @State private var map = Map(url: .sample1)!
    
    var body: some View {
        MapView(map: map)
            .floatingPanel(selectedDetent: .constant(.half), horizontalAlignment: .leading, isPresented: $isPresented) {
                Forms(map: map)
                    .padding()
            }
    }
}
    }
}
