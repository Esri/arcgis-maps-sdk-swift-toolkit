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
import ArcGISToolkit
import SwiftUI

@main
struct OfflineMapAreasExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            OfflineMapAreasExampleView()
        }
        // Setup the offline toolkit components.
        .offlineManager(preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30)) { job in
            // Post a local notification that the job is finished.
            Self.notifyJobCompleted(job: job)
        }
    }
}

extension OfflineMapAreasExampleApp {
    /// Posts a local notification that the job completed with success or failure.
    static func notifyJobCompleted(job: any JobProtocol) {
        guard
            job.status == .succeeded || job.status == .failed,
            let job = job as? DownloadPreplannedOfflineMapJob,
            let preplannedMapArea = job.parameters.preplannedMapArea,
            let id = preplannedMapArea.portalItem.id
        else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
        
        content.title = "Download \(jobStatus)"
        content.body = "The job for \(preplannedMapArea.portalItem.title) has \(jobStatus.lowercased())."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = id.rawValue
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
