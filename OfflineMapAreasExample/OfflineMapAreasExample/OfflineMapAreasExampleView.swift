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

import ArcGIS
import ArcGISToolkit
import SwiftUI
import UserNotifications

@MainActor
struct OfflineMapAreasExampleView: View {
    /// The map of the Naperville water network.
    @State private var onlineMap = Map(item: PortalItem.naperville())
    
    /// The selected map.
    @State private var selectedOfflineMap: Map?
    
    /// A Boolean value indicating whether the offline map ares view should be presented.
    @State private var isShowingOfflineMapAreasView = false
    
    var body: some View {
        NavigationStack {
            MapView(map: selectedOfflineMap ?? onlineMap)
                .navigationTitle("Offline Example")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Menu") {
                            Button("Go Online") {
                                selectedOfflineMap = nil
                            }
                            .disabled(selectedOfflineMap == nil)
                            Button("Offline Maps") {
                                isShowingOfflineMapAreasView = true
                            }
                        }
                    }
                }
                .sheet(isPresented: $isShowingOfflineMapAreasView) {
                    OfflineMapAreasView(onlineMap: onlineMap, selection: $selectedOfflineMap)
                        .task { await requestUserNotificationAuthorization() }
                }
        }
    }
    
    /// Requests authorization to show notifications.
    private func requestUserNotificationAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }
}

private extension PortalItem {
    static func naperville() -> PortalItem {
        PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
        )
    }
}
