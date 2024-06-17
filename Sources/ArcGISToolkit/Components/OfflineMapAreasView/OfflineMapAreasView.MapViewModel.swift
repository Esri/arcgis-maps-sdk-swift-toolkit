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
import SwiftUI
import UIKit

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private let portalItemID: Item.ID?
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            portalItemID = map.item?.id
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the
        /// offline map models.
        func makePreplannedOfflineMapModels() async {
            guard let portalItemID else { return }
            
            preplannedMapModels = await Result {
                try await offlineMapTask.preplannedMapAreas
                    .filter { $0.id != nil }
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .map {
                        PreplannedMapModel(
                            offlineMapTask: offlineMapTask,
                            mapArea: $0,
                            portalItemID: portalItemID,
                            preplannedMapAreaID: $0.id!
                        )
                    }
            }
        }
        
        /// Request authorization to show notifications.
        func requestUserNotificationAuthorization() async {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
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
