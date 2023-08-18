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

@MainActor
public class JobManager: ObservableObject {
    public struct ID: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public static let `default` = JobManager(id: .init(rawValue: "default"))
    
    private let id: ID
    
    private var defaultsKey: String {
        return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
    }
    
    @objc func appMovedToBackground() {
        saveJobs()
    }
    
    public init(id: ID) {
        self.id = id
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        loadJobs()
    }
    
    @Published
    public var jobs: [any JobProtocol] = []
    
    /// Adds a job to the job manager.
    ///
    /// - Parameter job: The job to register.
    public func add(job: any JobProtocol) {
        jobs.append(job)
    }
    
    /// Removes a job from the job manager.
    ///
    /// - Parameter job: The job to unregister.
    public func remove(job: any JobProtocol) {
        guard let index = jobs.firstIndex(where: { $0 === job }) else { return }
        jobs.remove(at: index)
    }
    
    public func removeAllJobs() {
        jobs.removeAll()
    }
    
    /// Saves all managed jobs to User Defaults.
    private func saveJobs() {
        let array = jobs.map { $0.toJSON() }
        UserDefaults.standard.setValue(array, forKey: defaultsKey)
    }
    
    /// Load any jobs that have been saved to User Defaults.
    private func loadJobs() {
        guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
            return
        }
        
        jobs = strings.compactMap {
            try? Job.fromJSON($0) as? any JobProtocol
        }
    }
    
    public func performStatusChecks() async {
        await withTaskGroup(of: Void.self) { group in
            for job in jobs {
                group.addTask {
                    try? await job.checkStatus()
                }
            }
        }
    }
}
