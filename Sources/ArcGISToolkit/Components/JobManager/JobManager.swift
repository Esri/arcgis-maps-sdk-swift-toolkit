// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import SwiftUI
import ArcGIS
import BackgroundTasks
import OSLog

/// An enum that defines a schedule for background status checks.
public enum BackgroundStatusCheckSchedule {
    /// No background status checks will be requested.
    case disabled
    /// Requests that the system schedule a background check at a regular interval.
    /// Ultimately it is up to the discretion of the system if that check is run.
    case regularInterval(interval: TimeInterval)
}

extension Logger {
    /// A logger for the job manager.
    static let jobManager = Logger(subsystem: "com.esri.ArcGISToolkit", category: "JobManager")
}

/// An object that manages saving jobs when the app is backgrounded and can reload them later.
@MainActor
public class JobManager: ObservableObject {
    /// The shared job manager.
    public static let `shared` = JobManager()
    
    /// The jobs being managed by the job manager.
    @Published
    public var jobs: [any JobProtocol] = []
    
    /// The key for which state will be serialized under the user defaults.
    private var defaultsKey: String {
        return "com.esri.ArcGISToolkit.jobManager.jobs"
    }
    
    /// The preferred schedule for performing status checks while the application is in the
    /// background. This allows an application to check to see if jobs have completed and optionally
    /// post a local notification to update the user. The default value is `disabled`.
    /// When the value of this property is not `disabled`, this setting is just a preference.
    /// The operating system ultimately decides when to allow a background task to run.
    /// If you enable background status checks then you must also make sure to have enabled
    /// "Background Fetch" and "Background Processing" background modes in your application settings.
    /// You must also add "com.esri.ArcGISToolkit.jobManager.statusCheck" to the "Permitted background task scheduler identifiers"
    /// in your application's plist file.
    /// More information can be found here: https://developer.apple.com/documentation/backgroundtasks/refreshing_and_maintaining_your_app_using_background_tasks
    public var preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule = .disabled
    
    /// The background task identifier for status checks.
    private let statusChecksTaskIdentifier = "com.esri.ArcGISToolkit.jobManager.statusCheck"
    
    // A Boolean value indicating whether a background status check is scheduled.
    private var isBackgroundStatusChecksScheduled = false
    
    /// An initializer for the job manager.
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: statusChecksTaskIdentifier, using: nil) { task in
            // Reset flag because once the task is launched, we need to reschedule if we want to do
            // another background task.
            self.isBackgroundStatusChecksScheduled = false
            Task {
                Logger.jobManager.debug("Performing status checks.")
                await self.performStatusChecks()
                Logger.jobManager.debug("Status checks completed.")
                self.scheduleBackgroundStatusCheck()
                task.setTaskCompleted(success: true)
            }
        }
        
        // Load jobs from the saved state.
        loadState()
    }
    
    /// Schedules a status check in the background if one is not already scheduled.
    private func scheduleBackgroundStatusCheck() {
        // Return if already scheduled.
        guard !isBackgroundStatusChecksScheduled else {
            return
        }
        
        // Do not schedule if there are no running jobs.
        guard hasRunningJobs else {
            return
        }
        
        // Make sure the preferred background status check schedule
        guard case .regularInterval(let timeInterval) = preferredBackgroundStatusCheckSchedule else {
            return
        }
        
        isBackgroundStatusChecksScheduled = true
        
        let request = BGAppRefreshTaskRequest(identifier: statusChecksTaskIdentifier)
        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: Int(timeInterval), to: .now)
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.jobManager.debug("Background task scheduled.")
        } catch(let error) {
            Logger.jobManager.error("Background task scheduling error \(error.localizedDescription)")
        }
    }
    
    /// A Boolean value indicating if there are jobs running.
    private var hasRunningJobs: Bool {
        !jobs.filter({ $0.status == .started }).isEmpty
    }
    
    /// Called when the app moves to the background.
    @objc private func appWillResignActive() {
        // Schedule background status checks.
        scheduleBackgroundStatusCheck()
        
        // Save the jobs to the user defaults when the app moves to the background.
        saveState()
    }
    
    /// Called when the app will be terminated.
    @objc private func appWillTerminate() {
        Logger.jobManager.debug("App will terminate.")
        // Save the jobs to the user defaults when the app will be terminated to save the latest state.
        saveState()
    }
    
    /// Check the status of all managed jobs.
    public func performStatusChecks() async {
        await withTaskGroup(of: Void.self) { group in
            for job in jobs {
                group.addTask {
                    try? await job.checkStatus()
                }
            }
        }
    }
    
    /// Resumes all paused jobs.
    public func resumeAllPausedJobs() {
        // Make sure the default background URL session is re-created here
        // in case this method is called from an app relaunch due to background downloads
        // completed for a terminated app. We need the session to be re-created in that case.
        _ = ArcGISEnvironment.backgroundURLSession
        
        jobs.filter { $0.status == .paused }
            .forEach { $0.start() }
    }

    /// Saves all managed jobs to User Defaults.
    public func saveState() {
        Logger.jobManager.debug("Saving state.")
        let array = jobs.map { $0.toJSON() }
        UserDefaults.standard.setValue(array, forKey: defaultsKey)
    }
    
    
    /// Load any jobs that have been saved to User Defaults.
    private func loadState() {
        Logger.jobManager.debug("Loading state.")
        guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
            return
        }
        
        jobs = strings.compactMap {
            try? Job.fromJSON($0) as? any JobProtocol
        }
    }
}
