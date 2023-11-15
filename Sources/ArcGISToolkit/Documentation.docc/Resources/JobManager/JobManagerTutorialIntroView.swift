import ArcGIS
import ArcGISToolkit
import SwiftUI

struct JobManagerTutorialView: View {
    /// The job manager used by this view.
    @ObservedObject var jobManager = JobManager.shared
    /// The job that this view shows data for.
    @State private var job: Job?
    /// The job's error in case of failure.
    @State private var error: Error?
    /// A Boolean value indicating if we are currently adding an offline map job.
    @State private var isAddingOfflineMapJob = false
    /// The job's status.
    @State private var status: Job.Status = .notStarted

    init() {
        // Ask the job manager to schedule background status checks for every 30 seconds.
        jobManager.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
    }

    var body: some View {
        VStack {
            if let job {
                ProgressView(job.progress)
                    .progressViewStyle(.linear)
                    .padding()
                HStack {
                    Button("Start Job", action: job.start)
                        .disabled(status != .notStarted)
                    Button {
                        jobManager.jobs.removeAll()
                        self.job = nil
                    } label: {
                        Text("Remove Job")
                    }
                    .disabled(status == .started)
                }
                .buttonStyle(.bordered)
                .padding()
                .task() {
                    for await jobStatus in job.$status {
                        status = jobStatus
                        if status == .failed || status == .succeeded {
                            notifyJobCompleted()
                        }
                    }
                }
            } else {
                HStack(spacing: 10) {
                    if isAddingOfflineMapJob {
                        ProgressView()
                    }
                    Button {
                        isAddingOfflineMapJob = true
                        Task {
                            do {
                                jobManager.jobs.append(
                                    try await makeNapervilleOfflineMapJob()
                                )
                            } catch {
                                print("Error creating offline map job: \(error)")
                            }
                            job = jobManager.jobs.first
                            isAddingOfflineMapJob = false
                        }
                    } label: {
                        Text("Take Map Offline")
                    }
                    .buttonStyle(.bordered)
                    .disabled(isAddingOfflineMapJob)
                    .padding()

                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
                if let error {
                    print(error.localizedDescription)
                }
            }
            if job == nil, jobManager.jobs.count > 0 {
                job = jobManager.jobs.first
            }
        }
    }
    /// Posts a local notification that the job completed.
    func notifyJobCompleted() {
        guard let job else { return }
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "Job Completed"
        content.subtitle = "\(type(of: job))"
        content.body = "Status: \(String(describing: job.status))"
        content.categoryIdentifier = "Job Completion"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "My Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension JobManagerTutorialView {
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
