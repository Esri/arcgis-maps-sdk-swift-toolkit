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

import ArcGIS
import SwiftUI

/// A view that displays a map.
@MainActor
struct MapItemView: View {
    /// The map that is to be displayed.
    let map: Map
    
    /// The result of loading the map.
    @State private var loadResult: Result<Void, Error>?
    
    var body: some View {
        VStack {
            switch loadResult {
            case .none:
                ProgressView()
            case .success:
                MapView(map: map)
                    .edgesIgnoringSafeArea(.top)
            case .failure(let error):
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            guard loadResult == nil else { return }
            loadResult = await Result { try await map.load() }
        }
    }
}
