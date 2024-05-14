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

/// An object that encapsulates state about a preplanned map.
public class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: PreplannedMapArea
    
    /// The task to use to take the area offline.
    let offlineMapTask: OfflineMapTask
    
    /// The directory where the mmpk will be stored.
    let mmpkDirectory: URL
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// A Boolean value indicating whether the map is being taken offline.
    var isDownloading: Bool {
        job != nil
    }
    
    /// The result of the download job. When the result is `.success` the mobile map package is returned.
    /// If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
    /// map area is still packaging or loading.
    @Published private(set) var result: Result<MobileMapPackage, Error>?
    
    init?(
        offlineMapTask: OfflineMapTask,
        temporaryDirectory: URL,
        preplannedMapArea: PreplannedMapArea
    ) {
        self.offlineMapTask = offlineMapTask
        self.preplannedMapArea = preplannedMapArea
        
        if let itemID = preplannedMapArea.portalItem.id {
            self.mmpkDirectory = temporaryDirectory
                .appendingPathComponent(itemID.rawValue)
                .appendingPathExtension("mmpk")
        } else {
            return nil
        }
    }
}

extension PreplannedMapModel {
    /// Downloads the given preplanned map area.
    /// - Parameter preplannedMapArea: The preplanned map area to be downloaded.
    /// - Precondition: `canDownload`
    @MainActor
    func downloadPreplannedMapArea() async {
        precondition(canDownload)
        
        let parameters: DownloadPreplannedOfflineMapParameters
        
        do {
            // Creates the parameters for the download preplanned offline map job.
            parameters = try await makeParameters(preplannedMapArea: preplannedMapArea)
        } catch {
            // If creating the parameters fails, set the failure.
            self.result = .failure(error)
            return
        }
        
        // Creates the download preplanned offline map job.
        let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
            parameters: parameters,
            downloadDirectory: mmpkDirectory
        )
        
       // jobManager.jobs.append(job)
        
        self.job = job
        
        // Starts the job.
        job.start()
        
        // Awaits the output of the job and assigns the result.
        result = await job.result.map { $0.mobileMapPackage }
        
        // Sets the job to nil
        self.job = nil
    }
    
    /// A Boolean value indicating whether the offline map can be downloaded.
    /// This returns `false` if the map was already downloaded successfully or is in the process
    /// of being downloaded.
    var canDownload: Bool {
        !(isDownloading || downloadDidSucceed)
    }
    
    /// A Boolean value indicating whether the download succeeded.
    var downloadDidSucceed: Bool {
        if case .success = result {
            return true
        } else {
            return false
        }
    }
    
    /// Creates the parameters for a download preplanned offline map job.
    /// - Parameter preplannedMapArea: The preplanned map area to create parameters for.
    /// - Returns: A `DownloadPreplannedOfflineMapParameters` if there are no errors.
    func makeParameters(preplannedMapArea: PreplannedMapArea) async throws -> DownloadPreplannedOfflineMapParameters {
        // Creates the default parameters.
        let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: preplannedMapArea)
        // Sets the update mode to no updates as the offline map is display-only.
        parameters.updateMode = .noUpdates
        return parameters
    }
}

extension PreplannedMapModel: Hashable {
    public static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
