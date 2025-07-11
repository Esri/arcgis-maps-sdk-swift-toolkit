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
///
/// The button will cycle through the specified auto-pan modes on tap. The user
/// can also hide the location display or select the auto-pan mode through a
/// context menu.
///
/// If there are no auto-pan options specified, or if the only specified option
/// is `.off`, then the location display is toggled on/off with upon tap, and
/// the context menu is not shown on a long press.
public struct LocationButton: View {
    let locationDisplay: LocationDisplay
    
    /// The current status of the location display's datasource.
    @State var status: LocationDataSource.Status = .stopped
    
    /// The autopan mode of the location display.
    @State var autoPanMode: LocationDisplay.AutoPanMode = .off
    
    /// A value indicating whether the button is disabled.
    var buttonIsDisabled: Bool {
        status == .starting || status == .stopping
    }
    
    /// Backing variable for the auto pan options that are selectable by the user.
    var autoPanModes: [LocationDisplay.AutoPanMode] = [
        .recenter, .compassNavigation, .navigation, .off
    ]
    
    /// Creates a location button with a location display.
    /// - Parameter locationDisplay: The location display that the button will control.
    public init(locationDisplay: LocationDisplay) {
        self.locationDisplay = locationDisplay
    }
    
    /// Sets the auto-pan options that are available for the user to select.
    /// - Parameter options: The auto-pan options that the user can cycle through.
    /// - Returns: A new location button with the auto-pan options set.
    public func autoPanModes(_ autoPanModes: [LocationDisplay.AutoPanMode]) -> Self {
        var copy = self
        copy.autoPanModes = autoPanModes.unique()
        return copy
    }
    
    public var body: some View {
        Button {
            buttonAction()
        } label: {
            buttonLabel()
        }
        .onChange(of: autoPanModes) {
            // If current mode not in new options, then switch it out.
            if !autoPanModes.contains(autoPanMode) {
                select(autoPanMode: initialAutoPanMode)
            }
        }
        .contextMenu(ContextMenu { contextMenuContent() })
        .disabled(buttonIsDisabled)
        .task(id: ObjectIdentifier(locationDisplay)) { await observeStatus() }
        .task(id: ObjectIdentifier(locationDisplay)) { await observeAutoPanMode() }
        .animation(.default, value: autoPanMode)
    }
    
    @ViewBuilder
    private func buttonLabel() -> some View {
        // Decide what what image is in the button based on the status
        // and autopan mode.
        switch status {
        case .stopped:
            Image(systemName: "location.slash")
        case .starting, .stopping:
            ProgressView()
        case .started:
            Image(systemName: autoPanMode.imageSystemName)
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
        // Only show context menu if there are 2 or more auto-pan options and
        // status of the location display is started.
        if autoPanModes.count >= 2 && status == .started {
            Section("Autopan") {
                ForEach(contextMenuAutoPanOptions, id: \.self) { autoPanMode in
                    Button {
                        select(autoPanMode: autoPanMode)
                    } label: {
                        Label(autoPanMode.pickerText, systemImage: autoPanMode.imageSystemName)
                    }
                }
            }
            
            Button {
                Task {
                    await hideLocationDisplay()
                }
            } label: {
                Label("Hide Location", systemImage: "location.slash")
            }
        }
    }
}

extension LocationButton {
    /// The initail auto-pan mode to be used.
    var initialAutoPanMode: LocationDisplay.AutoPanMode {
        autoPanModes.first ?? .off
    }
    
    /// The context menu auto-pan mode options.
    /// The context menu options will be in the order the user specifies
    /// except the off option will be first.
    var contextMenuAutoPanOptions: [LocationDisplay.AutoPanMode] {
        return if autoPanModes.contains(.off) {
            [.off] + autoPanModes.filter { $0 != .off }
        } else {
            autoPanModes
        }
    }
    
    /// Observe the status of the location display datasource.
    func observeStatus() async {
        for await status in locationDisplay.dataSource.$status {
            self.status = status
        }
    }
    
    /// Observe the auto pan mode of the location display.
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
        // Set the mode on the location display, the model observes changes
        // on the location display and will update accordingly.
        locationDisplay.autoPanMode = autoPanMode
    }
    
    /// This should be called when the button is pressed.
    func buttonAction() {
        switch Action(status: status, autoPanOptions: autoPanModes) {
        case .start:
            // If the datasource is a system location datasource, then request authorization.
            if locationDisplay.dataSource is SystemLocationDataSource,
               CLLocationManager.shared.authorizationStatus == .notDetermined {
                CLLocationManager.shared.requestWhenInUseAuthorization()
            }
            Task {
                // Start the datasource, set initial auto pan mode.
                do {
                    locationDisplay.autoPanMode = initialAutoPanMode
                    try await locationDisplay.dataSource.start()
                } catch {
                    print("Error starting location display: \(error)")
                }
            }
        case .stop:
            Task { await hideLocationDisplay() }
        case .autoPanCycle:
            // Need to use the select method here so that last selected mode
            // gets set.
            select(autoPanMode: nextAutoPanMode(current: autoPanMode, initial: initialAutoPanMode))
        case .none:
            return
        }
    }
    
    /// The next auto pan mode to be used when cycling through auto pan modes.
    func nextAutoPanMode(current: LocationDisplay.AutoPanMode, initial: LocationDisplay.AutoPanMode) -> LocationDisplay.AutoPanMode {
        guard let index = autoPanModes.firstIndex(of: current) else { return initial }
        let nextIndex = index.advanced(by: 1) == autoPanModes.endIndex ? autoPanModes.startIndex : index.advanced(by: 1)
        return autoPanModes[nextIndex]
    }
    
    /// Hides the location display.
    func hideLocationDisplay() async {
        await locationDisplay.dataSource.stop()
    }
}

extension LocationButton {
    /// The type of actions that can take place when the button is pressed.
    enum Action {
        /// Start the location display.
        case start
        /// Stop the location display.
        case stop
        /// Set the next auto pan mode for cycling through.
        case autoPanCycle
        
        /// The action that should occur for the specified state.
        init?(
            status: LocationDataSource.Status,
            autoPanOptions: [LocationDisplay.AutoPanMode]
        ) {
            // Decide the button behavior based on the status.
            switch status {
            case .stopped, .failedToStart:
                self = .start
            case .started:
                if autoPanOptions.count < 2 {
                    // If there were no non-off options specified then set it to off
                    // if the status is started.
                    self = .stop
                } else {
                    self = .autoPanCycle
                }
            case .starting, .stopping:
                return nil
            @unknown default:
                fatalError()
            }
        }
    }
}

private extension LocationDisplay.AutoPanMode {
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
            "field.of.view.wide.fill"
        case .navigation:
            "location.north.fill"
        case .recenter:
            "location.fill.viewfinder"
        case .off:
            "location"
        @unknown default:
            fatalError()
        }
    }
}

private extension Sequence where Iterator.Element: Hashable {
    /// Returns the unique values of the sequence with the order preserved.
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

@MainActor
private extension CLLocationManager {
    static let shared = CLLocationManager()
}

#Preview {
    @Previewable @State var locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    
    MapView(map: Map.openStreetMap())
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 18) {
                LocationButton(locationDisplay: locationDisplay)
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 8)
                
                LocationButton(locationDisplay: locationDisplay)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                
                LocationButton(locationDisplay: locationDisplay)
                    .imageScale(.large)
                    .frame(minWidth: 50, minHeight: 50)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 8)
                
                LocationButton(locationDisplay: locationDisplay)
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .imageScale(.large)
                    .bold()
                    .frame(minWidth: 50, minHeight: 50)
                    .background(.tint)
                    .clipShape(.circle)
                    .shadow(radius: 8)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                LocationButton(locationDisplay: locationDisplay)
            }
        }
}

private extension Map {
   static func openStreetMap() -> Map {
       Map(basemap: .init(baseLayer: OpenStreetMapLayer()))
    }
}
