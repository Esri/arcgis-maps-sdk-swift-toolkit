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

import ArcGIS
import Combine
import Foundation

public extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The online map.
        private let onlineMap: Map
        
        /// The portal item ID of the web map.
        private var portalItemID: String?
        
        /// The offline map of the downloaded preplanned map area.
        private var offlineMap: Map?
        
        /// The map used in the map view.
        var currentMap: Map { offlineMap ?? onlineMap }
        
        /// The offline map task.
        let offlineMapTask: OfflineMapTask
        
        /// The url for the preplanned map areas directory.
        let preplannedDirectory: URL
        
        /// The mobile map packages created from mmpk files in the documents directory.
        @Published private(set) var mobileMapPackages = [MobileMapPackage]()
        
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
        
        /// The job manager.
        let jobManager = JobManager.shared
        
        init(map: Map) {
            onlineMap = map
            
            // Sets the min scale to avoid requesting a huge download.
            onlineMap.minScale = 1e4
            
            offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
            
            if let portalItemID = map.item?.id?.rawValue {
                FileManager.default.createDirectories(for: portalItemID)
                
                preplannedDirectory = FileManager.default.preplannedDirectory(portalItemID: portalItemID)
            } else {
                preplannedDirectory = FileManager.default.documentsDirectory
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
        
        /// Loads locally stored mobile map packages for the map's preplanned map areas.
        func loadPreplannedMobileMapPackages() {
            // Create mobile map packages with saved mmpk files.
            let mmpkFiles = searchFiles(in: preplannedDirectory, with: "mmpk")
            
            for fileURL in mmpkFiles {
                let mobileMapPackage = MobileMapPackage(fileURL: fileURL)
                self.mobileMapPackages.append(mobileMapPackage)
            }
        }
        
        /// Searches for files with a specified file extension in a given directory and its subdirectories.
        /// - Parameters:
        ///   - directory: The directory to search.
        ///   - fileExtension: The file extension to search for.
        /// - Returns: An array of file paths.
        func searchFiles(in directory: URL, with fileExtension: String) -> [URL] {
            guard let enumerator = FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { return [] }
            
            var files: [URL] = []
            
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == fileExtension {
                    files.append(fileURL)
                }
            }
            return files
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
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory.
    private var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(path: "OfflineMapAreas", directoryHint: .isDirectory)
    }
    
    /// The path to the web map directory.
    private func webMapDirectory(portalItemID: String) -> URL {
        offlineMapAreasDirectory.appending(path: portalItemID, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory.
    func preplannedDirectory(portalItemID: String) -> URL {
        webMapDirectory(portalItemID: portalItemID).appending(path: "Preplanned", directoryHint: .isDirectory)
    }
    
    func createDirectories(for portalItemID: String) {
        Task.detached {
            // Create directory for offline map areas.
            try FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
            
            // Create directory for the webmap.
            try FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
            
            // Create directory for preplanned map areas.
            try FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
        }
    }
}
