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
import ArcGISToolkit
import OSLog
import SwiftUI
import UserNotifications

@MainActor
struct JobManagerExampleView: View {
    /// The job manager used by this view.
    @ObservedObject var jobManager = JobManager.shared
    /// A Boolean value indicating if we are currently adding a geodatabase job.
    @State private var isAddingGeodatabaseJob = false
    /// A Boolean value indicating if we are currently adding an offline map job.
    @State private var isAddingOfflineMapJob = false
    
    init() {
        // Ask the job manager to schedule background status checks for every 30 seconds.
        jobManager.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()
                if isAddingGeodatabaseJob || isAddingOfflineMapJob {
                    ProgressView()
                }
                menu
            }
            List(jobManager.jobs, id: \.id) { job in
                HStack {
                    JobView(job: job)
                    Button {
                        jobManager.jobs.removeAll(where: { $0 === job })
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
                if let error {
                    print(error.localizedDescription)
                }
            }
        }
        .padding()
    }
    
    /// The jobs menu.
    var menu: some View {
        Menu {
            Button {
                isAddingGeodatabaseJob = true
                Task {
                    do {
                        jobManager.jobs.append(
                            try await makeWildfiresGeodatabaseJob()
                        )
                    } catch {
                        Logger.jobManagerExample.error("Error creating generate geodatabase job: \(error, privacy: .public)")
                    }
                    isAddingGeodatabaseJob = false
                }
            } label: {
                Label("Generate Geodatabase", systemImage: "plus")
            }
            .disabled(isAddingGeodatabaseJob)
            
            Button {
                isAddingOfflineMapJob = true
                Task {
                    do {
                        jobManager.jobs.append(
                            try await makeNapervilleOfflineMapJob()
                        )
                    } catch {
                        Logger.jobManagerExample.error("Error creating offline map job: \(error, privacy: .public)")
                    }
                    isAddingOfflineMapJob = false
                }
            } label: {
                Label("Take Map Offline", systemImage: "plus")
            }
            .disabled(isAddingOfflineMapJob)
            
            Divider()
            
            Button {
                jobManager.jobs.removeAll()
            } label: {
                Label("Remove All Jobs", systemImage: "trash")
            }
            
            Button {
                jobManager.jobs.removeAll {
                    $0.status == .failed || $0.status == .succeeded
                }
            } label: {
                Label("Remove All Completed Jobs", systemImage: "trash")
            }
        } label: {
            Text("Jobs")
        }
    }
}

/// A view that displays data for a job.
private struct JobView: View {
    /// The job that this view shows data for.
    var job: Job
    /// The job's error in case of failure.
    @State private var error: Error?
    /// The job's status.
    @State private var status: Job.Status
    /// The latest job message.
    @State private var message: JobMessage?
    
    /// Initializer that takes a job for which to show the data for.
    init(job: Job) {
        self.job = job
        status = job.status
    }
    
    /// A Boolean value indicating if the progress is showing.
    var isShowingProgress: Bool {
        job.status == .started || (job.status == .paused && job.progress.fractionCompleted > 0)
    }
    
    /// A Boolean value indicating if the cancel button is showing.
    var isShowingCancel: Bool {
        job.status == .started || job.status == .paused
    }
    
    /// A string for the job's type.
    var jobType: String {
        "\(type(of: job))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(jobType)
            Text(status.displayText)
                .font(.footnote)
            if let error {
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                if let message {
                    Text(message.text)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if isShowingProgress {
                    ProgressView(job.progress)
                        .progressViewStyle(.linear)
                        .padding(.vertical)
                }
                HStack {
                    if status == .started {
                        Button("Pause", action: job.pause)
                    } else if status == .paused {
                        Button("Resume", action: job.start)
                    } else if status == .notStarted {
                        Button("Start", action: job.start)
                    }
                    Spacer()
                    if isShowingCancel {
                        Button("Cancel") {
                            Task { await job.cancel() }
                        }
                    }
                }
                .buttonStyle(.borderless)
                .padding(.top, 2)
            }
        }
        .padding()
        .onReceive(job.$status) {
            status = $0
            if status == .failed || status == .succeeded {
                notifyJobCompleted()
            }
        }
        .onReceive(job.messages) {
            Logger.jobManagerExample.debug("Job Message: \($0.text, privacy: .public)")
            message = $0
        }
    }
    
    /// Posts a local notification that the job completed.
    func notifyJobCompleted() {
        Logger.jobManagerExample.debug("Posting local notification that job completed: \(status.displayText, privacy: .public)")
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "Job Completed"
        content.subtitle = jobType
        content.body = status.displayText
        content.categoryIdentifier = "Job Completion"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "My Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension Job.Status {
    /// Display text for the status.
    var displayText: String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .started:
            return "Started"
        case .paused:
            return "Paused"
        case .succeeded:
            return "Succeeded"
        case .failed:
            return "Failed"
        case .canceling:
            return "Canceling"
        @unknown default:
            return "Unknown"
        }
    }
}

extension JobManagerExampleView {
    /// Creates a job that generates a geodatabase for a wildfire service.
    func makeWildfiresGeodatabaseJob() async throws -> GenerateGeodatabaseJob {
        let url = URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer")!
        return try await makeGenerateGeodatabaseJob(url: url, syncModel: .layer)
    }
    
    /// Creates a job that generates an offline map for Naperville.
    func makeNapervilleOfflineMapJob() async throws -> GenerateOfflineMapJob {
        let portalItem = PortalItem(url: URL(string: "https://www.arcgis.com/home/item.html?id=acc027394bc84c2fb04d1ed317aac674")!)!
        let map = Map(item: portalItem)
        let naperville = Envelope(
            xMin: -9813416.487598,
            yMin: 5126112.596989,
            xMax: -9812775.435463,
            yMax: 5127101.526749,
            spatialReference: SpatialReference.webMercator
        )
        return try await makeOfflineMapJob(map: map, extent: naperville)
    }
    
    /// Creates a generate geodatabase job.
    /// - Parameters:
    ///   - url: The URL to the task.
    ///   - syncModel: The sync model for the geodatabase.
    ///   - extent: The extent of the generated geodatabase.
    func makeGenerateGeodatabaseJob(url: URL, syncModel: Geodatabase.SyncModel, extent: Envelope? = nil) async throws -> GenerateGeodatabaseJob {
        let task = GeodatabaseSyncTask(url: url)
        try await task.load()
        
        let params = GenerateGeodatabaseParameters()
        params.extent = extent ?? task.featureServiceInfo?.fullExtent
        params.outSpatialReference = extent?.spatialReference ?? SpatialReference.webMercator
        params.syncModel = syncModel
        
        if syncModel == .layer, let featureServiceInfo = task.featureServiceInfo {
            let layerOptions = featureServiceInfo.layerInfos
                .compactMap({ $0 as? FeatureServiceLayerIDInfo })
                .compactMap(\.id)
                .map(GenerateLayerOption.init(layerID:))
            params.addLayerOptions(layerOptions)
        }
        
        let downloadURL = FileManager.default.documentsPath.appendingPathComponent(UUID().uuidString).appendingPathExtension("geodatabase")
        
        let job = task.makeGenerateGeodatabaseJob(
            parameters: params,
            downloadFileURL: downloadURL
        )
        
        return job
    }
    
    /// Creates an offline map job.
    /// - Parameters:
    ///   - map: The map to take offline.
    ///   - extent: The extent of the offline area.
    func makeOfflineMapJob(map: Map, extent: Envelope) async throws -> GenerateOfflineMapJob {
        let task = OfflineMapTask(onlineMap: map)
        let params = try await task.makeDefaultGenerateOfflineMapParameters(areaOfInterest: extent)
        let downloadURL = FileManager.default.documentsPath.appendingPathComponent(UUID().uuidString)
        return task.makeGenerateOfflineMapJob(parameters: params, downloadDirectory: downloadURL)
    }
}

extension FileManager {
    /// The path to the documents folder.
    var documentsPath: URL {
        URL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        )
    }
}

public extension JobProtocol {
    /// The id of the job.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
