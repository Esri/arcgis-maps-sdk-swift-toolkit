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
        // Apply the `.offlineManager(referredBackgroundStatusCheckSchedule:jobCompletionAction:)` scene modifier
        // at the entry point of the application to setup background download support for the offline component.
        // Use of this scene modifier is required for the offline component to complete map area download jobs when
        // the app is backgrounded.
        //
        // Set the `preferredBackgroundStatusCheckSchedule` to `.regularInterval(interval: 30)` to check the status
        // of the download job in the background every 30 seconds. Use the `jobCompletionAction` closure to send
        // a notification once a download job completes.
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
            job.status == .succeeded || job.status == .failed
        else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
        
        content.title = "Download \(jobStatus)"
        content.body = "An offline job has \(jobStatus.lowercased())."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
