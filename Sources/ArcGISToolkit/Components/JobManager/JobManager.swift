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

import SwiftUI
import ArcGIS
import BackgroundTasks

/// An object that manages saving jobs when the app is backgrounded and can reload them later.
@MainActor
public class JobManager: ObservableObject {
    /// An identifier for the job manager.
    public struct ID: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// The default job manager.
    public static let `default` = JobManager(id: .init(rawValue: "default"))
    
    /// The unique id of the job manager.
    private let id: ID
    
    /// The jobs being managed by the job manager.
    @Published
    public var jobs: [any JobProtocol] = []
    
    /// The key for which state will be serialized under the user defaults.
    private var defaultsKey: String {
        return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
    }
    
    private let backgroundTaskIdentifier = "com.esri.ArcGISToolkit.jobManager.statusCheck"
    
    /// An initializer that takes an ID for the job manager.
    /// It is the callers responsibility to make sure the ID is unique.
    public init(id: ID) {
        self.id = id
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovingToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.isBackgroundStatusChecksScheduled = false
            Task {
                print("-- performing status checks")
                await self.performStatusChecks()
                self.scheduleBackgroundStatusCheck()
                task.setTaskCompleted(success: true)
            }
        }
        
        // Load jobs from the saved state.
        loadState()
    }
    
    
    var isBackgroundStatusChecksScheduled = false
    
    func scheduleBackgroundStatusCheck() {
        // Return if already scheduled.
        guard !isBackgroundStatusChecksScheduled else {
            return
        }
        
        // Do not schedule if there are no running jobs.
        guard !JobManager.default.jobs.filter({ $0.status == .started }).isEmpty else {
            return
        }
        
        isBackgroundStatusChecksScheduled = true
        
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 30, to: .now)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("-- Background Task Scheduled!")
        } catch(let error) {
            print("-- Scheduling Error \(error.localizedDescription)")
        }
    }
    
    /// Called when the app moves to the background.
    @objc private func appMovingToBackground() {
        // schedule background status checks
        scheduleBackgroundStatusCheck()
        
        // Save the jobs to the user defaults when the app moves to the background.
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
    
    /// Saves all managed jobs to User Defaults.
    private func saveState() {
        let array = jobs.map { $0.toJSON() }
        UserDefaults.standard.setValue(array, forKey: defaultsKey)
    }
    
    
    /// Load any jobs that have been saved to User Defaults.
    private func loadState() {
        guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
            return
        }
        
        jobs = strings.compactMap {
            try? Job.fromJSON($0) as? any JobProtocol
        }
    }
}
