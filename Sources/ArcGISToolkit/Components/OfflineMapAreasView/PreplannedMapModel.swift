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
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: PreplannedMapArea
    
    /// The result of the download job. When the result is `.success` the mobile map package is returned.
    /// If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
    /// map area is still packaging or loading.
    @Published private(set) var result: Result<MobileMapPackage, Error>?
    
    /// The combined status of the preplanned map area.
    @Published private(set) var status: Status = .notLoaded
    
    init(preplannedMapArea: PreplannedMapArea) {
        self.preplannedMapArea = preplannedMapArea
        
        // Kick off a load of the map area.
        Task.detached { await self.load() }
    }
    
    /// Loads the preplanned map area and updates the status.
    private func load() async {
        do {
            // Load preplanned map area to obtain packaging status.
            status = .loading
            try await preplannedMapArea.retryLoad()
            // Note: Packaging status is `nil` for compatibility with
            // legacy webmaps that have incomplete metadata.
            // If the area loads, then you know for certain the status is complete.
            updateStatus(for: preplannedMapArea.packagingStatus ?? .complete)
        } catch is IllegalStateError {
            // Load will throw an illegal state error if not complete,
            // this case is not a normal load failure.
            updateStatus(for: preplannedMapArea.packagingStatus ?? .failed)
        } catch {
            // Normal load failure.
            status = .loadFailure(error)
        }
    }
    
    /// Updates the status for a given packaging status.
    private func updateStatus(for packagingStatus: PreplannedMapArea.PackagingStatus) {
        // Update area status for a given packaging status.
        switch packagingStatus {
        case .processing:
            status = .packaging
        case .failed:
            status = .packageFailure
        case .complete:
            status = .packaged
        }
    }
}

extension PreplannedMapModel {
    /// The status of the preplanned map area model.
    enum Status {
        /// Preplanned map area not loaded.
        case notLoaded
        /// Preplanned map area is loading.
        case loading
        /// Preplanned map area failed to load.
        case loadFailure(Error)
        /// Preplanned map area is packaging.
        case packaging
        /// Preplanned map area is packaged and ready for download.
        case packaged
        /// Preplanned map area packaging failed.
        case packageFailure
        /// Preplanned map area is being downloaded.
        case downloading
        /// Preplanned map area is downloaded.
        case downloaded
        /// Preplanned map area failed to download.
        case downloadFailure(Error)
    }
}
