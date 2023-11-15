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
