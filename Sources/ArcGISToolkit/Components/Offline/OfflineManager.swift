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
import SwiftUI

/// An object that maintains state for the offline components.
@MainActor
class OfflineManager {
    /// The shared offline manager.
    static let `shared` = OfflineManager()
    
    /// The action to perform when a job completes.
    var jobCompletionAction: ((any JobProtocol) -> Void)?
    
    /// The job manager used by the offline manager.
    let jobManager = JobManager.shared
    
    /// The jobs managed by this instance.
    var jobs: [any JobProtocol] { jobManager.jobs }
    
    private init() {
        // Observe each job's status
        for job in jobManager.jobs {
            observeJob(job)
        }
        
        // Resume all paused jobs
        jobManager.resumeAllPausedJobs()
    }
    
    /// Starts a job that will be managed by this instance.
    /// - Parameter job: The job to start.
    func start(job: any JobProtocol) {
        jobManager.jobs.append(job)
        observeJob(job)
        job.start()
    }
    
    /// Observes a job for completion.
    private func observeJob(_ job: any JobProtocol) {
        Task {
            // Wait for job to finish.
            _ = try? await job.output
            
            // Remove completed job from JobManager.
            jobManager.jobs.removeAll { $0 === job }
            
            // Call job completion action.
            jobCompletionAction?(job)
        }
    }
}

private extension Job.Status {
    /// A Boolean value indicating whether the job is completed.
    var isComplete: Bool {
        switch self {
        case .notStarted, .started, .paused, .canceling:
            false
        case .succeeded, .failed:
            true
        }
    }
}

public extension SwiftUI.Scene {
    /// Sets up the offline components for use.
    /// - Parameters:
    ///   - preferredBackgroundStatusCheckSchedule: The preferred background status check schedule. See ``JobManager/preferredBackgroundStatusCheckSchedule`` for more details.
    ///   - onJobCompletion: An action to perform when a job completes.
    @MainActor
    func offline(
        preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule,
        onJobCompletion: ((any JobProtocol) -> Void)? = nil
    ) -> some SwiftUI.Scene {
        // Set the background status check schedule.
        OfflineManager.shared.jobManager.preferredBackgroundStatusCheckSchedule = preferredBackgroundStatusCheckSchedule
        
        // Set callback for job completion.
        OfflineManager.shared.jobCompletionAction = onJobCompletion
        
        // Support app-relaunch after background downloads.
        return self.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            // Allow the `ArcGISURLSession` to handle it's background task events.
            await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
            
            // When the app is re-launched from a background url session, resume any paused jobs,
            // and check the job status.
            await OfflineManager.shared.jobManager.resumeAllPausedJobs()
        }
    }
}
