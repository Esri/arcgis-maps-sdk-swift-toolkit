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
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// A Boolean value indicating whether the map has preplanned map areas.
        @Published private(set) var hasPreplannedMapAreas = false
        
        /// A Boolean value indicating whether the user has authorized notifications to be shown.
        var canShowNotifications = false
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            portalItemID = map.item?.id?.rawValue
            JobManager.shared.resumeAllPausedJobs()
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
        
        /// Request authorization to show notifications.
        func checkCanShowNotifications() async {
            canShowNotifications = (
                try? await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound])
            )
            ?? false
        }
    }
}

private extension FileManager {
    static let preplannedDirectoryPath: String = "Preplanned"
    static let offlineMapAreasPath: String = "OfflineMapAreas"
    
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory within the documents directory.
    var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: Self.offlineMapAreasPath,
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
            path: Self.preplannedDirectoryPath,
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
