// Copyright 2024 Esri
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
import ArcGIS

@MainActor
public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @State private var mapViewModel: MapViewModel
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public init(map: Map) {
        self.mapViewModel = MapViewModel(map: map)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preplanned Map Areas").bold()) {
                    preplannedMapAreas
                }
                .textCase(nil)
            }
            .task {
                await mapViewModel.makePreplannedOfflineMapModels()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Offline Maps")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder private var preplannedMapAreas: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            List(models) { preplannedMapModel in
                PreplannedListItemView(
                    preplannedMapModel: preplannedMapModel,
                    mapViewModel: mapViewModel
                )
            }
        case .failure(let error):
            Text(error.localizedDescription)
        case .none:
            ProgressView().frame(maxWidth: .infinity)
        }
    }
}

public extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The online map.
        private let onlineMap: Map
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        init(map: Map) {
            self.onlineMap = map
            
            offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the
        /// offline map models.
        func makePreplannedOfflineMapModels() async {
            self.preplannedMapModels = await Result {
                try await offlineMapTask.preplannedMapAreas
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .compactMap {
                        PreplannedMapModel(
                            preplannedMapArea: $0
                        )
                    }
            }
        }
    }
}
