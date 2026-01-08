// Copyright 2025 Esri
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
import BackgroundTasks

#if !os(visionOS) && !targetEnvironment(macCatalyst)
@available(iOS 26.0, *)
public extension BGContinuedProcessingTask {
    /// Binds a job to this continued processing task such that the job progress
    /// is monitored and updates the task progress accordingly.
    /// - Parameter job: The job to bind to.
    /// - Since: 300.0
    @MainActor
    func bind(to job: some JobProtocol) {
        // Cancel job if task expires or is cancelled.
        expirationHandler = {
            Task.detached { await job.cancel() }
        }
        
        // Set initial progress on the task.
        let taskProgress = progress
        taskProgress.totalUnitCount = 100
        
        // Observe progress on the job and update the task.
        Task {
            let observer = job.progress.observe(\.fractionCompleted, options: [.initial]) { progress, _ in
                taskProgress.completedUnitCount = Int64(progress.fractionCompleted * 100)
            }
            
            let result = await job.result
            observer.invalidate()
            let success = switch result {
            case .success: true
            case .failure: false
            }
            setTaskCompleted(success: success)
        }
    }
}
#endif
