// Copyright 2024 Esri
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

import SwiftUI
import ArcGIS

public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @StateObject private var mapViewModel: MapViewModel
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    /// The rotation angle of the reload button image.
    @State private var rotationAngle: CGFloat = 0.0
    
    public init(map: Map) {
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: map))
        
        // Ask the job manager to schedule background status checks for every 30 seconds.
        JobManager.shared.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: HStack {
                    Text("Preplanned Map Areas").bold()
                    Spacer()
                    Button {
                        withAnimation(.linear(duration: 0.6)) {
                            rotationAngle = rotationAngle + 360
                        }
                        Task {
                            await mapViewModel.makePreplannedOfflineMapModels()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .controlSize(.mini)
                }.frame(maxWidth: .infinity)
                ) {
                    preplannedMapAreas
                }
                .textCase(nil)
            }
            .task {
                await mapViewModel.makePreplannedOfflineMapModels()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                mapViewModel.canShowNotifications = (
                    try? await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound])
                )
                ?? false
            }
            .navigationTitle("Offline Maps")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder private var preplannedMapAreas: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            if mapViewModel.hasPreplannedMapAreas {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(
                        model: preplannedMapModel,
                        canShowNotifications: mapViewModel.canShowNotifications
                    )
                }
            } else {
                emptyPreplannedMapAreasView
            }
        case .failure(let error):
            if error.localizedDescription == "The Internet connection appears to be offline." && !mapViewModel.offlinePreplannedModels.isEmpty {
                List(mapViewModel.offlinePreplannedModels.sorted(by: < ), id: \.preplannedMapArea.title) { model in
                    PreplannedListItemView(
                        mapViewModel: mapViewModel,
                        model: model
                    )
                }
            } else {
                VStack(alignment: .center) {
                    Image(systemName: "exclamationmark.circle")
                        .imageScale(.large)
                        .foregroundStyle(.red)
                    Text(error.localizedDescription)
                }
                .frame(maxWidth: .infinity)
            }
        case .none:
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var emptyPreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No offline map areas")
                .bold()
            Text("You don't have any offline map areas yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Loads the preplanned map area models and mobile map packages.
    private func loadPreplannedMapAreas() async {
        await mapViewModel.makePreplannedOfflineMapModels()
        mapViewModel.loadPreplannedMobileMapPackages()
        mapViewModel.loadOfflinePreplannedMapModels()
    }
}

#Preview {
    OfflineMapAreasView(
        map: Map(
            item: PortalItem(
                portal: .arcGISOnline(connection: .anonymous),
                id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
            )
        )
    )
}

extension PreplannedMapModel: Comparable {
    public static func < (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
        return lhs.preplannedMapArea.title < rhs.preplannedMapArea.title
    }
}
