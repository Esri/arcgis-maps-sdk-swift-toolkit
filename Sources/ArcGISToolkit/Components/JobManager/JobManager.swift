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

public typealias JobID = String

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
        print("App moved to background!")
        saveJobs()
    }
    
    public init(id: ID) {
        self.id = id
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        loadJobs()
    }
    
    private var isSavingSuppressed = false
    
    // TODO: is this needed?
    private func withSavingSuppressed<T>(body: @Sendable @MainActor () throws -> T) rethrows -> T {
        isSavingSuppressed = true
        defer { isSavingSuppressed = false }
        return try body()
    }
    
    private var _jobs: [JobID: any JobProtocol] = [:] {
        willSet {
            objectWillChange.send()
        }
    }
    
    public var jobs: [any JobProtocol] {
        Array(_jobs.values)
    }
    
    /// Registers a job with the job manager.
    ///
    /// - Parameter job: The job to register.
    /// - Returns: A unique ID for the job's registration which can be used to unregister the job.
    @discardableResult
    public func register(job: any JobProtocol) -> JobID {
        let id = UUID().uuidString
        _jobs[id] = job
        return id
    }
    
    /// Unregisters a job from the job manager.
    ///
    /// - Parameter id: The job's ID, returned from calling `register()`.
    /// - Returns: `true` if the Job was found, `false` otherwise.
    @discardableResult
    public func unregister(id: JobID) -> Bool {
        let removed = _jobs.removeValue(forKey: id) != nil
        return removed
    }

    /// Unregisters a job from the job manager.
    ///
    /// - Parameter job: The job to unregister.
    /// - Returns: `true` if the Job was found, `false` otherwise.
    @discardableResult
    public func unregister(job: any JobProtocol) -> Bool {
        guard let keyValue = _jobs.first(where: { $0.value === job }) else {
            return false
        }
        
        return unregister(id: keyValue.key)
    }
    
    /// Saves all managed jobs to User Defaults.
    private func saveJobs() {
        guard !isSavingSuppressed else { return }
        let dictionary = _jobs.mapValues { $0.toJSON() }
        UserDefaults.standard.setValue(dictionary, forKey: defaultsKey)
    }
    
    /// Load any jobs that have been saved to User Defaults.
    private func loadJobs() {
        guard let dictionary = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [JobID: String] else {
            return
        }
        
        withSavingSuppressed {
            _jobs = dictionary.compactMapValues {
                try? Job.fromJSON($0) as? any JobProtocol
            }
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
