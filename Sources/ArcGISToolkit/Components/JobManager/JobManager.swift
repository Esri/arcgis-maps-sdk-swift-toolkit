// Copyright 2023 Esri
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
import Combine
import Foundation
import OSLog
import UIKit

/// An object that manages saving and loading jobs so that they can continue to run if the
/// app is backgrounded or even terminated.
///
/// The job manager is instantiable, but the ``shared`` instance is suitable for most applications.
///
/// **Background**
///
/// Jobs are long running server operations. When a job instance is started on the client,
/// it makes a request to a service asking it to start work on the server. At that point, the client
/// polls the server intermittently to check the status of the work. Once the work is completed
/// the result is downloaded with a background `URLSession`. This allows the download to
/// complete out of process, and the download task can relaunch the app upon completion, even
/// in the case where the app was terminated.
///
/// We do not expect users to keep an application in the foreground and wait for a job to complete.
/// Once the job is started, if the app is backgrounded, we can use an app refresh
/// background task to check the status of the work on the server. If the server work is complete
/// we can start downloading the result in the background at that point. If the work on the server
/// is not complete, we can reschedule another background app refresh to recheck status.
///
/// There is some iOS behavior to be aware of as well. In iOS, if an application is backgrounded,
/// the operating system can terminate the app at its discretion. This means that jobs need to be
/// serialized when an app is backgrounded so that if the app is terminated the jobs can be
/// rehydrated upon relaunch of the app.
///
/// Also in iOS if the user of an app removes the app from the app switcher (swiping up) then the
/// system interprets this as a strong indication that the user does not want the app running.
/// The consequences of this are two-fold for jobs. One, any background fetch tasks are not given
/// any time until the app is relaunched again. And two, any background downloads that are in
/// progress are canceled by the operating system.
///
/// **Features**
///
/// The job manager is an `ObservableObject` with a mutable ``jobs`` property. Adding a job to this
/// property will allow the job manager to do the work to make sure that we can rehydrate a job
/// if an app is terminated.
///
/// As such, the job manager will:
///
///  - Serialize the job to the user defaults when the app is backgrounded
///  - Deserialize the job when an application is relaunched
///
/// The job manager will help with the lifetime of jobs in other ways as well.
///
/// The job manager will ask the system for some background processing time when an app
/// is backgrounded so that jobs that are not yet started on the server, can have some time to
/// allow them to start. This means if you kick off a job and it hasn't actually started on the server
/// when the app is backgrounded, the job should have enough time to start on the server which
/// will cause it to enter into a polling state. When the job reaches the polling state the
/// status of the work on the server can be checked intermittently.
///
/// To enable polling while an app is backgrounded, the job manager will request from the system a
/// background refresh task (if enabled via the ``JobManager/preferredBackgroundStatusCheckSchedule``
/// property). If the system later executes the background refresh task then the
/// job manager will check the status of any running jobs. At that point the jobs may start
/// downloading their result. Note, this does not work on the simulator, this behavior can only
/// be tested on an actual device.
///
/// Now that the job can check status in the background, it can start downloading in the background.
/// By default, jobs will download their results with background URL session. This means that the
/// download can execute out of process, even if the app is terminated. If the app is terminated and
/// then later relaunched by the system because a background downloaded completed, then you may
/// call the ``JobManager/resumeAllPausedJobs()`` method from the application relaunch point,
/// which will correlate the jobs to their respective downloads that completed and the jobs will
/// then finish. The app relaunch point can happen via the SwiftUI modifier `.backgroundTask(.urlSession(...))`.
/// In UIKit it would be the `UIApplicationDelegate` method `func application(UIApplication, handleEventsForBackgroundURLSession: String, completionHandler: () -> Void)`
/// - Since: 200.3
@MainActor
public class JobManager: ObservableObject {
    /// The shared job manager.
    public static let shared = JobManager(id: nil)
    
    /// The jobs being managed by the job manager.
    @Published
    public var jobs: [any JobProtocol] = []
    
    /// The key for which state will be serialized under the user defaults.
    var defaultsKey: String {
        if let id {
            "com.esri.ArcGISToolkit.jobManager.\(id).jobs"
        } else {
            "com.esri.ArcGISToolkit.jobManager.jobs"
        }
    }
    
    /// The preferred schedule for performing status checks while the application is in the
    /// background. This allows an application to check to see if jobs have completed and optionally
    /// post a local notification to update the user. The default value is `disabled`.
    /// When the value of this property is not `disabled`, this setting is just a preference.
    /// The operating system ultimately decides when to allow a background task to run.
    /// If you enable background status checks then you must also make sure to have enabled
    /// the "Background fetch" background mode in your application settings.
    ///
    /// - Note: You must also add the ``statusChecksTaskIdentifier`` to the "Permitted
    /// background task scheduler identifiers" in your application's plist file.
    /// The status checks task identifier will be "com.esri.ArcGISToolkit.jobManager.statusCheck" if using the shared instance.
    /// If you are using a job manager instance that you created with a specific ID, then the
    /// identifier will be "com.esri.ArcGISToolkit.jobManager.<id>.statusCheck".
    ///
    /// Background checks only work on device and not on the simulator.
    /// More information can be found [here](https://developer.apple.com/documentation/backgroundtasks/refreshing_and_maintaining_your_app_using_background_tasks).
    public var preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule = .disabled
    
    /// The background task identifier for status checks.
    /// - SeeAlso ``preferredBackgroundStatusCheckSchedule``
    public var statusChecksTaskIdentifier: String {
        if let id {
            "com.esri.ArcGISToolkit.jobManager.\(id).statusCheck"
        } else {
            "com.esri.ArcGISToolkit.jobManager.statusCheck"
        }
    }
    
    /// A Boolean value indicating whether a background status check is scheduled.
    private var isBackgroundStatusChecksScheduled = false
    
    /// The id of the job manager. The shared instance does not have an id.
    var id: String?
    
    /// An initializer for the job manager.
    private init(id: String?) {
        self.id = id
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
    
    /// Creates a job manager with a unique id.
    /// This initializer allows you to create a specific instance of a job manager
    /// for cases when you don't want to take over the shared job manager instance.
    ///
    /// The provided ID should be unique to a specific purpose in your application.
    /// On each successive run of the app, you must re-use the same id when you initialize
    /// your job manager for it to be able to properly reload its state.
    ///
    /// If you create multiple instances with the same id the behavior is undefined.
    /// - Parameter id: The unique ID of the job manager.
    public convenience init(uniqueID id: String) {
        self.init(id: id)
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
        jobs.contains { $0.status == .started }
    }
    
    /// Called when the app moves back to the foreground.
    @objc private func appWillEnterForeground() {
        // End any current background task.
        endCurrentBackgroundTask()
    }
    
    /// Called when the app moves to the background.
    @objc private func appWillResignActive() {
        // Start a background task if necessary.
        beginBackgroundTask()
        
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
        // Make sure the default background URLSession is re-created here
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
    
    /// Load any jobs that have been saved to UserDefaults.
    private func loadState() {
        Logger.jobManager.debug("Loading state.")
        guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
            return
        }
        
        jobs = strings.compactMap {
            try? Job.fromJSON($0) as? any JobProtocol
        }
    }
    
    /// The current background task identifier.
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    /// Ends any current background task.
    private func endCurrentBackgroundTask() {
        guard let backgroundTaskIdentifier else {
            Logger.jobManager.debug("No current background task to end.")
            return
        }
        Logger.jobManager.debug("Ending current background task.")
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        self.backgroundTaskIdentifier = nil
    }
    
    /// Starts a background task for extended time in the background if we have jobs that are
    /// started but have yet to begin polling.
    private func beginBackgroundTask() {
        // Jobs that are started but do not yet have a server job ID are jobs that
        // can benefit from starting a background task for extra execution time.
        // This will hopefully allow a job to get to the polling state before the app is suspended.
        // Once in a polling state that's where background refreshes can check job status.
        if !jobs.contains(where: ({ $0.status == .started && $0.serverJobID.isEmpty })) {
            Logger.jobManager.debug("No jobs that require starting a background task.")
            return
        }
        
        // Already started.
        guard backgroundTaskIdentifier == nil else {
            Logger.jobManager.debug("Background task already started.")
            return
        }
        
        Logger.jobManager.debug("Starting a background task.")
        
        let identifier = UIApplication.shared.beginBackgroundTask() {
            Logger.jobManager.debug("Out of background processing time.")
            self.endCurrentBackgroundTask()
        }
        
        self.backgroundTaskIdentifier = identifier
    }
}

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
    ///
    /// To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER" under Scheme
    /// -> Arguments -> Environment Variables
    static let jobManager: Logger = {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER") {
            return Logger(subsystem: "com.esri.ArcGISToolkit", category: "JobManager")
        } else {
            return Logger(OSLog.disabled)
        }
    }()
}
