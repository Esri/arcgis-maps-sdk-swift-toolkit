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

/// A button that allows a user to show their location on a map view.
/// Gives the user a variety of options to set the auto pan mode or stop the
/// location datasource.
public struct LocationButton: View {
    /// The location display which the button controls.
    @State private var locationDisplay: LocationDisplay
    /// The current status of the location display's datasource.
    @State private var status: LocationDataSource.Status = .stopped
    /// The autopan mode of the location display.
    @State private var autoPanMode: LocationDisplay.AutoPanMode = .off
    /// The last selected autopan mode by the user.
    @State private var lastSelectedAutoPanMode = LocationDisplay.AutoPanMode.recenter
    
    /// Creates a location button with a location display.
    /// - Parameter locationDisplay: The location display that the button will control.
    public init(locationDisplay: LocationDisplay) {
        self.locationDisplay = locationDisplay
        self.autoPanMode = locationDisplay.autoPanMode
    }
    
    public var body: some View {
        Button {
            buttonAction()
        } label: {
            buttonLabel()
        }
        .contextMenu(
            ContextMenu { contextMenuContent() }
        )
        .disabled(status == .starting || status == .stopping)
        .onReceive(locationDisplay.dataSource.$status) { status = $0 }
        .onReceive(locationDisplay.$autoPanMode) { autoPanMode = $0 }
        .onChange(of: autoPanMode) { autoPanMode in
            if autoPanMode != locationDisplay.autoPanMode {
                locationDisplay.autoPanMode = autoPanMode
                if autoPanMode != .off {
                    lastSelectedAutoPanMode = autoPanMode
                }
            }
        }
    }
    
    @MainActor
    private func buttonAction() {
        // Decide the button behavior based on the status.
        switch status {
        case .stopped, .failedToStart:
            // If the datasource is a system location datasource, then request authorization.
            if locationDisplay.dataSource is SystemLocationDataSource,
               CLLocationManager.shared.authorizationStatus == .notDetermined {
                CLLocationManager.shared.requestWhenInUseAuthorization()
            }
            Task {
                // Start the datasource.
                do {
                    try await locationDisplay.dataSource.start()
                } catch {
                    print("Error starting location display: \(error)")
                }
            }
        case .started:
            // If the datasource is started then decide what to do based
            // on the autopan mode.
            switch autoPanMode {
            case .off:
                // If autopan is off, then set it to the last selected autopan mode.
                locationDisplay.autoPanMode = lastSelectedAutoPanMode
            default:
                // Otherwise set it to off.
                locationDisplay.autoPanMode = .off
            }
        case .starting, .stopping:
            break
        @unknown default:
            fatalError()
        }
    }
    
    @ViewBuilder private func buttonLabel() -> some View {
        // Decide what what image is in the button based on the status
        // and autopan mode.
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
    
    @MainActor
    @ViewBuilder
    private func contextMenuContent() -> some View {
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
}

@MainActor
private extension CLLocationManager {
    static let shared = CLLocationManager()
}

#Preview {
    LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
}
