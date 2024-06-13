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
import UIKit

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private let portalItemID: String?
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The url for the preplanned map areas directory.
        private var preplannedDirectory: URL?
        
        /// The preplanned map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// The offline preplanned map information.
        @Published private(set) var offlinePreplannedModels = [PreplannedMapModel]()
        
        /// A Boolean value indicating whether the map has preplanned map areas.
        @Published private(set) var hasPreplannedMapAreas = false
        
        /// A Boolean value indicating whether the user has authorized notifications to be shown.
        var canShowNotifications = false
        
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
            if let models = try? preplannedMapModels!.get() {
                hasPreplannedMapAreas = !models.isEmpty
                
                for model in models {
                    model.setMobileMapPackage()
                }
            }
        }
        
        /// Loads the offline preplanned map models using metadata json files.
        func loadOfflinePreplannedMapModels() {
            offlinePreplannedModels.removeAll()
            
            let jsonFiles = searchFiles(in: preplannedDirectory, with: "json")
            
            for fileURL in jsonFiles {
                if let (offlinePreplannedMapArea, mobileMapPackage) = parseJSONFile(for: fileURL),
                   let offlinePreplannedMapArea,
                   let mobileMapPackage {
                    offlinePreplannedModels.append(
                        PreplannedMapModel(
                            preplannedMapArea: offlinePreplannedMapArea,
                            mobileMapPackage: mobileMapPackage
                        )
                    )
                }
            }
        }
        
        /// Parses the json from a metadata file for the preplanned map area.
        /// - Parameter fileURL: The file URL of the metadata json file.
        /// - Returns: An `OfflinePreplannedMapArea` instantiated using the metadata json
        /// and the mobile map package for the preplanned map area.
        func parseJSONFile(for fileURL: URL) -> (OfflinePreplannedMapArea?, MobileMapPackage?)? {
            do {
                let contentString = try String(contentsOf: fileURL)
                let jsonData = Data(contentString.utf8)
                
                let thumbnailURL = fileURL
                    .deletingPathExtension()
                    .deletingLastPathComponent()
                    .appending(path: "thumbnail")
                    .appendingPathExtension("png")

                let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.relativePath)
                
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    guard let title = json["title"] as? String,
                          let description = json["description"] as? String,
                          let id = json["id"] as? String,
                          let itemID = Item.ID(id),
                          let path = json["mmpkURL"] as? String else { return nil }
                    let fileURL = URL(filePath: path)
                    let mobileMapPackage = MobileMapPackage(fileURL: fileURL)
                    return (
                        OfflinePreplannedMapArea(
                            packagingStatus: .complete,
                            title: title,
                            description: description, 
                            thumbnailImage: thumbnailImage,
                            id: itemID
                        ),
                        mobileMapPackage
                    )
                } else {
                    return nil
                }
            } catch {
                return nil
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
        
        func addOfflinePreplannedModel(
            for preplannedMap: PreplannedMapAreaProtocol,
            mobileMapPackage: MobileMapPackage?
        ) {
            offlinePreplannedModels.append(
                PreplannedMapModel(
                    preplannedMapArea: preplannedMap,
                    mobileMapPackage: mobileMapPackage
                )
            )
        }
    }
}

private extension OfflineMapAreasView.MapViewModel {
    /// The names of the folders used to save offline map areas.
    enum FolderNames {
        static var preplanned: String { "Preplanned" }
        static var offlineMapAreas: String { "OfflineMapAreas" }
    }
}

private extension FileManager {
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory. The offline map areas directory is located in the documents directory.
    var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: OfflineMapAreasView.MapViewModel.FolderNames.offlineMapAreas,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the web map directory for a specific portal item.
    func webMapDirectory(forItemID itemID: String) -> URL {
        offlineMapAreasDirectory.appending(path: itemID, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory for a specific portal item.
    func preplannedDirectory(forItemID itemID: String) -> URL {
        webMapDirectory(forItemID: itemID).appending(
            path: OfflineMapAreasView.MapViewModel.FolderNames.preplanned,
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
