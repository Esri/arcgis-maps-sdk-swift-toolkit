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

public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @StateObject private var mapViewModel: MapViewModel
    
    @ObservedObject var jobManager = JobManager.shared
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    /// The rotation angle of the reload button image.
    @State private var rotationAngle: CGFloat = 0.0
    
    public init(map: Map) {
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: map))
        
        // Ask the job manager to schedule background status checks for every 30 seconds.
        jobManager.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: HStack {
                    Text("Preplanned Map Areas").bold()
                    Spacer()
                    Button {
                        withAnimation(.linear(duration: 0.6)) {
                            rotationAngle = rotationAngle + 360
                        }
                        Task {
                            // Reload the preplanned map areas.
                            await mapViewModel.makePreplannedOfflineMapModels()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .controlSize(.mini)
                }.frame(maxWidth: .infinity)
                ) {
                    preplannedMapAreas
                }
                .textCase(nil)
            }
            .task {
                await mapViewModel.makePreplannedOfflineMapModels()
                mapViewModel.loadMobileMapPackages()
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
            if mapViewModel.hasPreplannedMapAreas {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(
                        mapViewModel: mapViewModel,
                        preplannedMapModel: preplannedMapModel
                    )
                }
            } else {
                emptyPreplannedMapAreasView
            }
        case .failure(let error):
            VStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                Text(error.localizedDescription)
            }
            .frame(maxWidth: .infinity)
        case .none:
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var emptyPreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No offline map areas")
                .bold()
            Text("You don't have any offline map areas yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

public extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The online map.
        private let onlineMap: Map
        
        /// The offline map of the downloaded preplanned map area.
        private var offlineMap: Map?
        
        /// The map used in the map view.
        var currentMap: Map { offlineMap ?? onlineMap }
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The url for the documents directory.
        private let documentsDirectory: URL = FileManager.default.documentsDirectory
        
        /// The mobile map packages created from mmpk files in the documents directory.
        @Published var mobileMapPackages = [MobileMapPackage]()
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// A Boolean value indicating whether the map has preplanned map areas.
        @Published private(set) var hasPreplannedMapAreas = false
        
        /// The currently selected map.
        @Published var selectedMap: SelectedMap = .onlineWebMap {
            didSet {
                selectedMapDidChange(from: oldValue)
            }
        }
        
        var jobManager = JobManager.shared
        
        init(map: Map) {
            self.onlineMap = map
            
            // Sets the min scale to avoid requesting a huge download.
            onlineMap.minScale = 1e4
            
            offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
        }
        
        deinit {
            // Removes the mmpks from the documents directory.
            if let files = try? FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ) {
                for url in files where url.pathExtension == "mmpk" {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the
        /// offline map models.
        func makePreplannedOfflineMapModels() async {
            preplannedMapModels = await Result {
                try await offlineMapTask.preplannedMapAreas
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .compactMap {
                        PreplannedMapModel(
                            offlineMapTask: offlineMapTask,
                            temporaryDirectory: documentsDirectory,
                            preplannedMapArea: $0,
                            mapViewModel: self
                        )
                    }
            }
            if let models = try? preplannedMapModels!.get() {
                hasPreplannedMapAreas = !models.isEmpty
            }
        }
        
        /// Handles a selection of a map.
        /// If the selected map is an offline map and it has not yet been taken offline, then
        /// it will start downloading. Otherwise the selected map will be used as the displayed map.
        func selectedMapDidChange(from oldValue: SelectedMap) {
            switch selectedMap {
            case .onlineWebMap:
                offlineMap = nil
            case .preplannedMap(let info):
                if info.canDownload {
                    // If we have not yet downloaded or started downloading, then kick off a
                    // download and reset selection to previous selection since we have to download
                    // the offline map.
                    selectedMap = oldValue
                    Task {
                        await info.downloadPreplannedMapArea()
                    }
                } else if case .success(let mmpk) = info.result {
                    // If we have already downloaded, then open the map in the mmpk.
                    offlineMap = mmpk.maps.first
                } else {
                    // If we have a failure, then keep the online map selected.
                    selectedMap = oldValue
                }
            }
        }
        
        func loadMobileMapPackages() {
            // Create mobile map packages with saved mmpk files.
            if let files = try? FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ) {
                for fileURL in files where fileURL.pathExtension == "mmpk" {
                    let mobileMapPackage = MobileMapPackage(fileURL: fileURL)
                    self.mobileMapPackages.append(mobileMapPackage)
                }
            }
        }
    }
}

public extension OfflineMapAreasView.MapViewModel {
    /// A type that specifies the currently selected map.
    enum SelectedMap: Hashable {
        /// The online version of the map.
        case onlineWebMap
        /// One of the preplanned offline maps.
        case preplannedMap(PreplannedMapModel)
    }
}

private extension FileManager {
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        )
    }
}

#Preview {
    OfflineMapAreasView(
        map: Map(
            item: PortalItem(
                portal: .arcGISOnline(connection: .anonymous),
                id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
            )
        )
    )
}
