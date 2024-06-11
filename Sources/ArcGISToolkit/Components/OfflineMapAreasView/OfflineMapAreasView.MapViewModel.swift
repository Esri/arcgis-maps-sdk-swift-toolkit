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

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private var portalItemID: String?
        
        /// The offline map of the downloaded preplanned map area.
        private var offlineMap: Map?
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The url for the preplanned map areas directory.
        private var preplannedDirectory: URL?
        
        /// The mobile map packages created from mmpk files in the documents directory.
        @Published private(set) var mobileMapPackages: [MobileMapPackage] = []
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// A Boolean value indicating whether the map has preplanned map areas.
        @Published private(set) var hasPreplannedMapAreas = false
        
        /// A Boolean value indicating whether the user has authorized notifications to be shown.
        var canShowNotifications = false
        
        /// The job manager.
        let jobManager = JobManager.shared
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            portalItemID = map.item?.id?.rawValue
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the
        /// offline map models.
        func makePreplannedOfflineMapModels() async {
            guard let portalItemID else { return }
            
            FileManager.default.createDirectories(for: portalItemID)
            preplannedDirectory = FileManager.default.preplannedDirectory(forItemID: portalItemID)
            
            guard let preplannedDirectory else { return }
            
            preplannedMapModels = await Result {
                try await offlineMapTask.preplannedMapAreas
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .compactMap {
                        PreplannedMapModel(
                            offlineMapTask: offlineMapTask,
                            mapArea: $0,
                            directory: preplannedDirectory
                        )
                    }
            }
            if let models = try? preplannedMapModels?.get() {
                hasPreplannedMapAreas = !models.isEmpty
            }
        }
        
        /// Sets locally stored mobile map packages for the map's preplanned map area models.
        func setPreplannedMobileMapPackages() {
            guard let preplannedDirectory else { return }
            // Create mobile map packages with saved mmpk files.
            self.mobileMapPackages = OfflineMapAreasView.MapViewModel.urls(in: preplannedDirectory, withPathExtension: "mmpk")
                .map(MobileMapPackage.init(fileURL:))
            
            // Set mobile map package for preplanned map models.
            if let models = try? preplannedMapModels?.get() {
                models.forEach { model in
                    if let mobileMapPackage = mobileMapPackages.first(where: {
                        $0.fileURL.deletingPathExtension().lastPathComponent == model.preplannedMapArea.id?.rawValue
                    }) {
                        model.setMobileMapPackage(mobileMapPackage)
                    }
                }
            }
        }
    }
}

private extension OfflineMapAreasView.MapViewModel {
    /// Recursively searches for files with a specified file extension in a given directory and its subdirectories.
    /// - Parameters:
    ///   - directory: The directory to search.
    ///   - pathExtension: The path extension to search for.
    /// - Returns: An array of file paths.
    static func urls(in directory: URL, withPathExtension pathExtension: String) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey]
        ) else { return [] }
        
        return enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == pathExtension }
    }
    
    /// The names of the folders used to save offline map areas.
    enum FolderNames: String {
        case preplanned = "Preplanned"
        case offlineMapAreas = "OfflineMapAreas"
    }
}

private extension FileManager {
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory. The offline map areas directory is located in the documents directory.
    private var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: OfflineMapAreasView.MapViewModel.FolderNames.offlineMapAreas.rawValue,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the web map directory for a specific portal item.
    private func webMapDirectory(forItemID itemID: String) -> URL {
        offlineMapAreasDirectory.appending(path: itemID, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory for a specific portal item.
    func preplannedDirectory(forItemID itemID: String) -> URL {
        webMapDirectory(forItemID: itemID).appending(
            path: OfflineMapAreasView.MapViewModel.FolderNames.preplanned.rawValue,
            directoryHint: .isDirectory
        )
    }
    
    /// Creates the directories needed to save a preplanned map area mobile map package and metadata
    /// with a given portal item ID.
    /// - Parameter portalItemID: The portal item ID.
    func createDirectories(for portalItemID: String) {
        // Create directory for offline map areas.
        try? FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
        
        // Create directory for the webmap.
        try? FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(forItemID: portalItemID), withIntermediateDirectories: true)
        
        // Create directory for preplanned map areas.
        try? FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(forItemID: portalItemID), withIntermediateDirectories: true)
    }
}
