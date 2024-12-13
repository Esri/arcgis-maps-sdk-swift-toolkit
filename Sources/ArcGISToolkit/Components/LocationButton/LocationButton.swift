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

extension LocationButton {
    @MainActor
    class Model: ObservableObject {
        /// The location display which the button controls.
        let locationDisplay: LocationDisplay
        
        /// The current status of the location display's datasource.
        @Published var status: LocationDataSource.Status = .stopped {
            didSet {
                buttonIsDisabled = status == .starting || status == .stopping
            }
        }
        
        /// The autopan mode of the location display.
        @Published var autoPanMode: LocationDisplay.AutoPanMode = .off {
            didSet {
                // Update last selected auto pan mode if the user selected one.
                if autoPanMode != locationDisplay.autoPanMode {
                    locationDisplay.autoPanMode = autoPanMode
                    if autoPanMode != .off {
                        // Do not update the last selected autopan mode here if
                        // `off` was selected by the user.
                        lastSelectedAutoPanMode = autoPanMode
                    }
                }
            }
        }
        
        /// A value indicating whether the button is disabled.
        @Published var buttonIsDisabled: Bool = true
        
        /// The last selected autopan mode by the user.
        var lastSelectedAutoPanMode: LocationDisplay.AutoPanMode
        
        /// The auto pan options that the user can choose from the context menu of the button.
        let autoPanOptions: Set<LocationDisplay.AutoPanMode>
        
        /// Creates a location button model with a location display.
        /// - Parameter locationDisplay: The location display that the button will control.
        /// - Parameter autoPanOptions: The auto pan options that will be selectable by the user.
        init(
            locationDisplay: LocationDisplay,
            autoPanOptions: Set<LocationDisplay.AutoPanMode> = [.off, .recenter, .compassNavigation, .navigation]
        ) {
            self.locationDisplay = locationDisplay
            self.autoPanMode = locationDisplay.autoPanMode
            self.autoPanOptions = autoPanOptions
            if autoPanOptions.isEmpty || (autoPanOptions.count == 1 && autoPanOptions.first == .off) {
                lastSelectedAutoPanMode = .off
            } else {
                lastSelectedAutoPanMode = LocationDisplay.AutoPanMode.orderedOptions
                    .lazy
                    .filter { $0 != .off }
                    .first { autoPanOptions.contains($0) } ?? .recenter
            }
        }
        
        func observeStatus() async {
            for await status in locationDisplay.dataSource.$status {
                self.status = status
            }
        }
        
        func observeAutoPanMode() async {
            for await autoPanMode in locationDisplay.$autoPanMode {
                self.autoPanMode = autoPanMode
            }
        }
        
        /// Selects a new auto pan mode.
        /// - Parameter autoPanMode: The new auto pan mode.
        func select(autoPanMode: LocationDisplay.AutoPanMode) {
            guard autoPanMode != locationDisplay.autoPanMode else {
                return
            }
            locationDisplay.autoPanMode = autoPanMode
            if autoPanMode != .off {
                // Do not update the last selected autopan mode here if
                // `off` was selected by the user.
                lastSelectedAutoPanMode = autoPanMode
            }
        }
        
        /// The action to perform when the button is pressed.
        func buttonAction() {
            // Decide the button behavior based on the status.
            switch status {
            case .stopped, .failedToStart:
                // If the datasource is a system location datasource, then request authorization.
                if locationDisplay.dataSource is SystemLocationDataSource,
                   CLLocationManager.shared.authorizationStatus == .notDetermined {
                    CLLocationManager.shared.requestWhenInUseAuthorization()
                }
                Task {
                    // Start the datasource, set initial auto pan mode.
                    do {
                        locationDisplay.autoPanMode = lastSelectedAutoPanMode
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
        
        /// Hides the location.
        func hideLocation() async {
            await locationDisplay.dataSource.stop()
        }
    }
}

/// A button that allows a user to show their location on a map view.
/// Gives the user a variety of options to set the auto pan mode or stop the
/// location datasource.
public struct LocationButton: View {
    @StateObject private var model: Model
    
    /// Creates a location button with a location display.
    /// - Parameter locationDisplay: The location display that the button will control.
    public init(
        locationDisplay: LocationDisplay,
        autoPanOptions: Set<LocationDisplay.AutoPanMode> = [.off, .recenter, .compassNavigation, .navigation]
    ) {
        _model = .init(wrappedValue: .init(locationDisplay: locationDisplay, autoPanOptions: autoPanOptions))
    }
    
    public var body: some View {
        Button {
            model.buttonAction()
        } label: {
            buttonLabel()
                .padding(8)
        }
        .contextMenu(
            ContextMenu { contextMenuContent() }
        )
        .disabled(model.buttonIsDisabled)
        .task { await model.observeStatus() }
        .task { await model.observeAutoPanMode() }
    }
    
    @ViewBuilder
    private func buttonLabel() -> some View {
        // Decide what what image is in the button based on the status
        // and autopan mode.
        switch model.status {
        case .stopped:
            Image(systemName: "location.slash")
        case .starting, .stopping:
            ProgressView()
        case .started:
            Image(systemName: model.autoPanMode.imageSystemName)
        case .failedToStart:
            Image(systemName: "exclamationmark.triangle")
                .tint(.secondary)
        @unknown default:
            fatalError()
        }
    }
    
    @MainActor
    @ViewBuilder
    private func contextMenuContent() -> some View {
        if model.status == .started {
            if model.autoPanOptions.count > 1 {
                Section("Autopan") {
                    ForEach(LocationDisplay.AutoPanMode.orderedOptions, id: \.self) { autoPanMode in
                        if model.autoPanOptions.contains(autoPanMode) {
                            Button {
                                model.select(autoPanMode: autoPanMode)
                            } label: {
                                Label(autoPanMode.pickerText, systemImage: model.autoPanMode.imageSystemName)
                            }
                        }
                    }
                }
            }
            
            Button {
                Task {
                    await model.hideLocation()
                }
            } label: {
                Label("Hide Location", systemImage: "location.slash")
            }
        }
    }
}

private extension LocationDisplay.AutoPanMode {
    /// The options that will appear in the picker, in order.
    static let orderedOptions: [Self] = [.off, .recenter, .compassNavigation, .navigation]
    
    /// The label that should appear in the picker.
    var pickerText: String {
        switch self {
        case .off:
            "Auto Pan Off"
        case .recenter:
            "Recenter"
        case .compassNavigation:
            "Compass"
        case .navigation:
            "Navigation"
        @unknown default:
            fatalError()
        }
    }
    
    /// The image associated with the auto pan mode.
    var imageSystemName: String {
        switch self {
        case .compassNavigation:
            "location.north.circle"
        case .navigation:
            "location.north.line.fill"
        case .recenter:
            "location.fill"
        case .off:
            "location"
        @unknown default:
            fatalError()
        }
    }
}

@MainActor
private extension CLLocationManager {
    static let shared = CLLocationManager()
}

#Preview {
    MapView(map: Map.openStreetMap())
        .overlay(alignment: .topTrailing) {
            VStack {
                LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                if #available(iOS 17.0, *) {
                    LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
                        .imageScale(.large)
                        .bold()
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .shadow(radius: 8)
                }
            }
            .padding()
        }
}

private extension Map {
   static func openStreetMap() -> Map {
       let map = Map(spatialReference: .webMercator)
       map.addOperationalLayer(OpenStreetMapLayer())
       return map
    }
}
