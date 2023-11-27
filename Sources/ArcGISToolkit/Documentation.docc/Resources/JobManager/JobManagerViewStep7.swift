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
                Button {
                    jobManager.jobs.removeAll()
                    self.job = nil
                } label: {
                    Text("Start New Job")
                }
                .opacity(status == .started ? 0.0 : 1.0)
                .buttonStyle(.bordered)
                .padding()
                .task {
                    for await jobStatus in job.$status {
                        status = jobStatus
                        if status == .failed || status == .succeeded {
                            notifyJobCompleted()
                            return
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
                            job?.start()
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
        }
    }
    
    /// Posts a local notification that the job completed.
    func notifyJobCompleted() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "Job Completed"
        content.subtitle = "Offline Map Job"
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
        }
    }
}

extension JobManagerTutorialView {
    /// Creates a job that generates an offline map for Naperville.
    func makeNapervilleOfflineMapJob() async throws -> GenerateOfflineMapJob {
        let map = Map(url:  URL(string: "https://www.arcgis.com/home/item.html?id=acc027394bc84c2fb04d1ed317aac674")!)!
        let naperville = Envelope(
            xMin: -9813416.487598,
            yMin: 5126112.596989,
            xMax: -9812775.435463,
            yMax: 5127101.526749,
            spatialReference: SpatialReference.webMercator
        )
        let task = OfflineMapTask(onlineMap: map)
        let params = try await task.makeDefaultGenerateOfflineMapParameters(areaOfInterest: naperville)
        let documentsPath = URL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        )
        let downloadURL = documentsPath.appendingPathComponent(UUID().uuidString)
        return task.makeGenerateOfflineMapJob(parameters: params, downloadDirectory: downloadURL)
    }
}
