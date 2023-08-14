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

public actor JobManager {
    public struct ID: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public static let shared = JobManager(id: .init(rawValue: "shared"))
    
    private let id: ID
    
    private var defaultsKey: String {
        return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
    }
    
    public init(id: ID) {
        self.id = id
    }
    
    private var isSavingSuppressed = false
    
    private func withSavingSuppressed<T>(body: @Sendable (isolated JobManager) throws -> T) rethrows -> T {
        isSavingSuppressed = true
        defer { isSavingSuppressed = false }
        return try body(self)
    }
    
    private var jobs: [any JobProtocol] = []
    
    /// Saves all managed jobs to User Defaults.
    ///
    /// This happens automatically when the jobs are registered/unregistered.
    /// It also happens when a job's status changes.
    private func saveJobsToUserDefaults() {
//        guard !suppressSaveToUserDefaults else { return }
//
//        UserDefaults.standard.set(self.toJSON(), forKey: jobsDefaultsKey)
    }
    
    /// Load any jobs that have been saved to User Defaults.
    private func loadJobsFromUserDefaults() {
//        if let storedJobsJSON = UserDefaults.standard.dictionary(forKey: jobsDefaultsKey) {
//            suppressSaveToUserDefaults = true
//            keyedJobs = storedJobsJSON.compactMapValues { $0 is JSONDictionary ? (try? AGSJob.fromJSON($0)) as? AGSJob : nil }
//            suppressSaveToUserDefaults = false
//        }
    }
}
