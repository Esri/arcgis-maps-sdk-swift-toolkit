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
import OSLog
import SwiftUI

/// An object that maintains state for the offline components.
@MainActor
class OfflineManager {
    /// The shared offline manager.
    static let shared = OfflineManager()
    
    /// The action to perform when a job completes.
    var jobCompletionAction: ((any JobProtocol) -> Void)?
    
    /// The job manager used by the offline manager.
    let jobManager = JobManager.shared
    
    /// The jobs managed by this instance.
    var jobs: [any JobProtocol] { jobManager.jobs }
    
    private init() {
        Logger.offlineManager.debug("Initializing OfflineManager")
        
        // Observe each job's status.
        for job in jobManager.jobs {
            observeJob(job)
        }
        
        // Resume all paused jobs.
        Logger.offlineManager.debug("Resuming all paused jobs")
        jobManager.resumeAllPausedJobs()
    }
    
    /// Starts a job that will be managed by this instance.
    /// - Parameter job: The job to start.
    func start(job: any JobProtocol) {
        Logger.offlineManager.debug("Starting Job from offline manager")
        jobManager.jobs.append(job)
        observeJob(job)
        job.start()
    }
    
    /// Observes a job for completion.
    private func observeJob(_ job: any JobProtocol) {
        Task {
            Logger.offlineManager.debug("Observing job completion")
            
            // Wait for job to finish.
            _ = try? await job.output
            
            // Remove completed job from JobManager.
            Logger.offlineManager.debug("Removing completed job from job manager")
            jobManager.jobs.removeAll { $0 === job }
            
            // This isn't strictly required, but it helps to get the state saved as soon
            // as possible after removing a job instead of waiting for the app to be backgrounded.
            jobManager.saveState()
            
            // Call job completion action.
            jobCompletionAction?(job)
        }
    }
}

public extension SwiftUI.Scene {
    /// Sets up the offline manager for offline toolkit components.
    /// - Parameters:
    ///   - preferredBackgroundStatusCheckSchedule: The preferred background status check schedule. See ``JobManager/preferredBackgroundStatusCheckSchedule`` for more details.
    ///   - jobCompletion: An action to perform when a job completes.
    @MainActor
    func offlineManager(
        preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule,
        jobCompletion jobCompletionAction: ((any JobProtocol) -> Void)? = nil
    ) -> some SwiftUI.Scene {
        Logger.offlineManager.debug("Executing OfflineManager SwiftUI.Scene modifier")
        
        // Set the background status check schedule.
        OfflineManager.shared.jobManager.preferredBackgroundStatusCheckSchedule = preferredBackgroundStatusCheckSchedule
        
        // Set callback for job completion.
        OfflineManager.shared.jobCompletionAction = jobCompletionAction
        
        // Support app-relaunch after background downloads.
        return self.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            Logger.offlineManager.debug("Executing OfflineManager backgroundTask")
            
            // Allow the `ArcGISURLSession` to handle its background task events.
            await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
            
            // When the app is re-launched from a background url session, resume any paused jobs,
            // and check the job status.
            await OfflineManager.shared.jobManager.resumeAllPausedJobs()
        }
    }
}

extension Logger {
    /// A logger for the offline manager.
    static var offlineManager: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_OFFLINE_MANAGER") {
            Logger(subsystem: "com.esri.ArcGISToolkit", category: "OfflineManager")
        } else {
            .init(.disabled)
        }
    }
}
