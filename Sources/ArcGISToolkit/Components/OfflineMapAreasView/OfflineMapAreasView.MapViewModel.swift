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
        /// The portal item ID of the web map.
        private var portalItemID: String?
        
        /// The offline map of the downloaded preplanned map area.
        private var offlineMap: Map?
        
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
        
        /// A Boolean value indicating whether the user has authorized notifications to be shown.
        @Published var canShowNotifications: Bool = false
        
        /// The job manager.
        let jobManager = JobManager.shared
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            
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
                            offlineMapTask: self.offlineMapTask,
                            preplannedDirectory: self.preplannedDirectory
                        )
                    }
            }
            if let models = try? preplannedMapModels?.get() {
                hasPreplannedMapAreas = !models.isEmpty
            }
        }
        
        /// Loads locally stored mobile map packages for the map's preplanned map areas.
        func loadPreplannedMobileMapPackages() {
            // Create mobile map packages with saved mmpk files.
            let mmpkFiles = searchFiles(in: preplannedDirectory, with: "mmpk")
            
            self.mobileMapPackages = mmpkFiles.map(MobileMapPackage.init(fileURL:))
            
            // Pass mobile map packages to preplanned map models.
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

private extension FileManager {
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory.
    private var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: OfflineMapAreasView.FolderNames.offlineMapAreas.rawValue,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the web map directory.
    private func webMapDirectory(portalItemID: String) -> URL {
        offlineMapAreasDirectory.appending(path: portalItemID, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory.
    func preplannedDirectory(portalItemID: String) -> URL {
        webMapDirectory(portalItemID: portalItemID).appending(
            path: OfflineMapAreasView.FolderNames.preplanned.rawValue,
            directoryHint: .isDirectory
        )
    }
    
    func createDirectories(for portalItemID: String) {
        // Create directory for offline map areas.
        try? FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
        
        // Create directory for the webmap.
        try? FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
        
        // Create directory for preplanned map areas.
        try? FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
    }
}

private extension OfflineMapAreasView {
    enum FolderNames: String {
        case preplanned = "Preplanned"
        case offlineMapAreas = "OfflineMapAreas"
    }
}
