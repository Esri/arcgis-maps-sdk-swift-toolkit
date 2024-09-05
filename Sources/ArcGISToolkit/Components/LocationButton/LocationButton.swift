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
import CoreLocation
import SwiftUI

public struct LocationButton: View {
    @State var locationDisplay: LocationDisplay
    @State private var status: LocationDataSource.Status = .stopped
    @State private var autoPanMode: LocationDisplay.AutoPanMode = .off
    @State private var lastSelectedAutoPanMode: LocationDisplay.AutoPanMode?
    
    public init(locationDisplay: LocationDisplay) {
        self.locationDisplay = locationDisplay
        self.autoPanMode = locationDisplay.autoPanMode
    }
    
    public var body: some View {
        Button {
            switch status {
            case .stopped, .failedToStart:
                if locationDisplay.dataSource is SystemLocationDataSource,
                   CLLocationManager.shared.authorizationStatus == .notDetermined {
                    CLLocationManager.shared.requestWhenInUseAuthorization()
                }
                Task {
                    do {
                        try await locationDisplay.dataSource.start()
                    } catch {
                        print("Error starting location display: \(error)")
                    }
                }
            case .started:
                switch autoPanMode {
                case .compassNavigation, .navigation, .recenter:
                    locationDisplay.autoPanMode = .off
                case .off:
                    if let lastSelectedAutoPanMode, lastSelectedAutoPanMode != .off {
                        locationDisplay.autoPanMode = lastSelectedAutoPanMode
                    } else {
                        locationDisplay.autoPanMode = .recenter
                    }
                @unknown default:
                    fatalError()
                }
            case .starting, .stopping:
                break
            @unknown default:
                fatalError()
            }
        } label: {
            Group {
                switch status {
                case .stopped:
                    Image(systemName: "location.slash")
                case .starting, .stopping:
                    ProgressView()
                case .started:
                    switch autoPanMode {
                    case .compassNavigation:
                        Image(systemName: "location.north.circle")
                    case .navigation:
                        Image(systemName: "location.north.line.fill")
                    case .recenter:
                        Image(systemName: "location.fill")
                    case .off:
                        Image(systemName: "location")
                    @unknown default:
                        fatalError()
                    }
                case .failedToStart:
                    Image(systemName: "exclamationmark.triangle")
                @unknown default:
                    fatalError()
                }
            }
        }
        .contextMenu(
            ContextMenu {
                if status == .started {
                    Section("Autopan") {
                        Picker("Autopan", selection: $autoPanMode) {
                            Text("Autopan Off").tag(LocationDisplay.AutoPanMode.off)
                            Text("Recenter").tag(LocationDisplay.AutoPanMode.recenter)
                            Text("Compass").tag(LocationDisplay.AutoPanMode.compassNavigation)
                            Text("Navigation").tag(LocationDisplay.AutoPanMode.navigation)
                        }
                    }
                    
                    Button {
                        Task {
                            await locationDisplay.dataSource.stop()
                        }
                    } label: {
                        Label("Stop Location", systemImage: "location.slash")
                    }
                }
            }
        )
        .disabled(status == .starting || status == .stopping)
        .onReceive(locationDisplay.dataSource.$status) { status = $0 }
        .onReceive(locationDisplay.$autoPanMode) { autoPanMode = $0 }
        .onChange(of: autoPanMode) { _, autoPanMode in
            if autoPanMode != locationDisplay.autoPanMode {
                locationDisplay.autoPanMode = autoPanMode
                if autoPanMode != .off {
                    lastSelectedAutoPanMode = autoPanMode
                }
            }
        }
    }
}

@MainActor
private extension CLLocationManager {
    static let shared = CLLocationManager()
}

#Preview {
    LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
}
