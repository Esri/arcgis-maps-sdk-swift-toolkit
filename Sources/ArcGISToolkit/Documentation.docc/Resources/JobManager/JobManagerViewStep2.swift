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
    
    var body: some View {
        VStack {
            if let job {
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
