// Copyright 2025 Esri
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

/// A button that allows a user to control their location display on a map view.
/// Gives the user a variety of options to set the auto-pan mode or stop the
/// location data source.
///
/// The button will cycle through the specified auto-pan modes on tap. The user
/// can also hide the location display or select the auto-pan mode through a
/// context menu.
///
/// If there are no auto-pan modes specified, or if the only specified mode is
/// `off`, then:
/// - the location display is toggled on/off when pressed
/// - the context menu is not shown when long pressed
public struct LocationButton: View {
    /// The location display controlled by the location button.
    let locationDisplay: LocationDisplay
    
    /// The current status of the location display's datasource.
    @State private(set) var status: LocationDataSource.Status = .stopped
    
    /// The auto-pan mode of the location display.
    @State private(set) var autoPanMode: LocationDisplay.AutoPanMode = .off
    
    /// A Boolean value indicating that the button action is being performed.
    @State private(set) var isPerformingButtonAction = false
    
    /// A value indicating whether the button is disabled.
    var buttonIsDisabled: Bool {
        status == .starting || status == .stopping || isPerformingButtonAction
    }

#if os(visionOS)
    /// The auto-pan modes that are selectable by the user.
    private(set) var autoPanModes: [LocationDisplay.AutoPanMode] = [
        .recenter, .off
    ]
#else
    /// The auto-pan modes that are selectable by the user.
    private(set) var autoPanModes: [LocationDisplay.AutoPanMode] = [
        .recenter, .compassNavigation, .off
    ]
#endif
    
    /// Creates a location button with a location display.
    /// - Parameter locationDisplay: The location display that the button will control.
    public init(locationDisplay: LocationDisplay) {
        self.locationDisplay = locationDisplay
    }
    
    /// Sets the auto-pan modes that are available for the user to select.
    /// - Parameter autoPanModes: The auto-pan modes that the user can cycle through.
    /// - Returns: A new location button with the auto-pan modes set.
    public func autoPanModes(_ autoPanModes: [LocationDisplay.AutoPanMode]) -> Self {
        var copy = self
        copy.autoPanModes = Array(autoPanModes.uniqued())
        return copy
    }
    
    public var body: some View {
        Button {
            buttonAction()
        } label: {
            buttonLabel
        }
        .contentTransition(.symbolEffect(.replace))
        .onChange(of: autoPanMode) {
            guard autoPanMode != locationDisplay.autoPanMode else {
                return
            }
            // Set the mode on the location display.
            locationDisplay.autoPanMode = autoPanMode
        }
        .onChange(of: autoPanModes) {
            // If current mode not in new options, then switch it out.
            if !autoPanModes.contains(autoPanMode) {
                autoPanMode = initialAutoPanMode
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(
            Text("Change location display options", bundle: .toolkitModule, comment: "The accessibility hint of the location button.")
        )
        .accessibilityValue(accessibilityValue)
        .contextMenu { contextMenuItems }
        .disabled(buttonIsDisabled)
        .task(id: ObjectIdentifier(locationDisplay)) { await observeStatus() }
        .task(id: ObjectIdentifier(locationDisplay)) { await observeAutoPanMode() }
        .animation(.default, value: autoPanMode)
    }
    
    /// The accessibility label of the button.
    private var accessibilityLabel: Text {
        switch status {
        case .stopped, .starting, .stopping, .failedToStart:
            Text(
                "Location display",
                bundle: .toolkitModule,
                comment: "The accessibility label of the location button when the location display is not showing."
            )
        case .started:
            Text(
                LocalizedStringResource(
                    "auto-pan-accessibility-label",
                    defaultValue: "Auto-pan",
                    bundle: .toolkit,
                    comment: """
                        The accessibility label of the location button when the 
                        location display is showing and the button cycles 
                        through auto-pan modes.
                        """
                )
            )
        @unknown default:
            fatalError()
        }
    }
    /// The accessibility value of the button.
    private var accessibilityValue: Text {
        switch status {
        case .stopped:
            Text(
                "Stopped",
                bundle: .toolkitModule,
                comment: "The accessibility value of the location button when the location display is not showing."
            )
        case .starting:
            Text(
                "Starting",
                bundle: .toolkitModule,
                comment: "The accessibility value of the location button when the location display is starting."
            )
        case .stopping:
            Text(
                "Stopping",
                bundle: .toolkitModule,
                comment: "The accessibility value of the location button when the location display is stopping."
            )
        case .failedToStart:
            Text(
                "Failed to start",
                bundle: .toolkitModule,
                comment: "The accessibility value of the location button when the location display fails to start."
            )
        case .started:
            switch autoPanMode {
            case .off:
                Text(
                    LocalizedStringResource(
                        "location-button-status-label-off",
                        defaultValue: "Off",
                        bundle: .toolkit,
                        comment: "The accessibility value of the location button when the auto-pan mode is off."
                    )
                )
            case .recenter:
                Text(
                    "Recenter",
                    bundle: .toolkitModule,
                    comment: "The accessibility value of the location button when the auto-pan mode is recenter."
                )
            case .compassNavigation:
                Text(
                    "Compass navigation",
                    bundle: .toolkitModule,
                    comment: "The accessibility value of the location button when the auto-pan mode is compass navigation."
                )
            case .navigation:
                Text(
                    LocalizedStringResource(
                        "location-button-status-label-navigation",
                        defaultValue: "Navigation",
                        bundle: .toolkit,
                        comment: "The accessibility value of the location button when the auto-pan mode is navigation."
                    )
                )
            @unknown default:
                fatalError("Unknown case")
            }
        @unknown default:
            fatalError()
        }
    }
    
    @ViewBuilder
    private var buttonLabel: some View {
        // Decide what image is in the button based on the status
        // and auto-pan mode.
        switch status {
        case .stopped:
            Image(systemName: "location.slash")
        case .starting, .stopping:
            ProgressView()
        case .started:
            Image(systemName: autoPanMode.imageSystemName)
        case .failedToStart:
            Image(systemName: "exclamationmark.triangle")
        @unknown default:
            fatalError()
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        // Only show context menu if there are 2 or more auto-pan options and
        // status of the location display is started.
        if autoPanModes.count >= 2 && status == .started {
            Section {
                ForEach(contextMenuAutoPanOptions, id: \.self) { autoPanMode in
                    Button {
                        self.autoPanMode = autoPanMode
                    } label: {
                        Label {
                            autoPanMode.label
                        } icon: {
                            Image(systemName: autoPanMode.imageSystemName)
                        }
                    }
                    .accessibilityHint(autoPanMode.accessibilityHint)
                }
            } header: {
                autoPanSectionHeaderLabelText
            }
            
            Button {
                Task {
                    await hideLocationDisplay()
                }
            } label: {
                Label {
                    hideLocationLabelText
                } icon: {
                    Image(systemName: "location.slash")
                }
            }
            .accessibilityHint(
                Text(
                    "Hide location display",
                    bundle: .toolkitModule,
                    comment: "The accessibility hint of the hide location display context menu option."
                )
            )
        }
    }
    
    /// The text for the auto-pan section in the context menu.
    private var autoPanSectionHeaderLabelText: Text {
        Text(
            LocalizedStringResource(
                "auto-pan-header-label",
                defaultValue: "Auto-pan",
                bundle: .toolkit,
                comment: "The header of the auto-pan section in the location button context menu."
            )
        )
    }
    
    /// The text for the hide location item in the context menu.
    private var hideLocationLabelText: Text {
        Text(
            "Hide Location",
            bundle: .toolkitModule,
            comment: "The section header for the auto-pan section in the location button context menu."
        )
    }
}

extension LocationButton {
    /// The initial auto-pan mode to be used.
    var initialAutoPanMode: LocationDisplay.AutoPanMode {
        autoPanModes.first ?? .off
    }
    
    /// The context menu auto-pan mode options.
    ///
    /// The context menu options will be in the order the user specifies
    /// except the off option will be first.
    var contextMenuAutoPanOptions: [LocationDisplay.AutoPanMode] {
        [.off] + autoPanModes.filter { $0 != .off }
    }
    
    /// Observe the status of the location display datasource.
    func observeStatus() async {
        for await status in locationDisplay.dataSource.$status {
            guard status != self.status else { continue }
            self.status = status
        }
    }
    
    /// Observe the auto-pan mode of the location display.
    func observeAutoPanMode() async {
        for await autoPanMode in locationDisplay.$autoPanMode {
            guard autoPanMode != self.autoPanMode else { continue }
            self.autoPanMode = autoPanMode
        }
    }
    
    /// This should be called when the button is pressed.
    func buttonAction() {
        isPerformingButtonAction = true
        
        switch Action(status: status, autoPanOptions: autoPanModes) {
        case .start:
            // If the datasource is a system location datasource, then request authorization.
            if locationDisplay.dataSource is SystemLocationDataSource,
               CLLocationManager.shared.authorizationStatus == .notDetermined {
                CLLocationManager.shared.requestWhenInUseAuthorization()
            }
            Task {
                // Start the datasource, set initial auto-pan mode.
                do {
                    locationDisplay.autoPanMode = initialAutoPanMode
                    try await locationDisplay.dataSource.start()
                } catch {
                    print("Error starting location display: \(error)")
                }
                isPerformingButtonAction = false
            }
        case .stop:
            Task {
                await hideLocationDisplay()
                isPerformingButtonAction = false
            }
        case .autoPanCycle:
            // Need to use the select method here so that last selected mode
            // gets set.
            autoPanMode = nextAutoPanMode(current: autoPanMode, initial: initialAutoPanMode)
            isPerformingButtonAction = false
        case .none:
            return
        }
    }
    
    /// The next auto-pan mode to be used when cycling through auto-pan modes.
    func nextAutoPanMode(current: LocationDisplay.AutoPanMode, initial: LocationDisplay.AutoPanMode) -> LocationDisplay.AutoPanMode {
        guard let index = autoPanModes.firstIndex(of: current) else { return initial }
        var nextIndex = autoPanModes.index(after: index)
        if nextIndex == autoPanModes.endIndex {
            nextIndex = autoPanModes.startIndex
        }
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
        /// Set the next auto-pan mode for cycling through.
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
                self = if autoPanOptions.count < 2 {
                    // Since there were no non-off options specified then set it
                    // to off since the status is started.
                    .stop
                } else {
                    .autoPanCycle
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
    /// The label text that should appear in the menu item.
    var label: Text {
        return switch self {
        case .off:
            Text(
                LocalizedStringResource(
                    "location-display-auto-pan-mode-label-off",
                    defaultValue: "Off",
                    bundle: .toolkit,
                    comment: "The label text for turning the auto-pan mode off in the location button context menu."
                )
            )
        case .recenter:
            Text(
                "Recenter",
                bundle: .toolkitModule,
                comment: "The label text for choosing the 'recenter' auto-pan mode in the location button context menu."
            )
        case .compassNavigation:
            Text(
                LocalizedStringResource(
                    "location-display-auto-pan-mode-label-compass",
                    defaultValue: "Compass",
                    bundle: .toolkit,
                    comment: "The label text for choosing the 'compass navigation' auto-pan mode in the location button context menu."
                )
            )
        case .navigation:
            Text(
                LocalizedStringResource(
                    "location-display-auto-pan-mode-label-navigation",
                    defaultValue: "Navigation",
                    bundle: .toolkit,
                    comment: "The label text for choosing the 'navigation' auto-pan mode in the location button context menu."
                )
            )
        @unknown default:
            fatalError()
        }
    }
    
    /// The accessibility hint for the context menu option for this auto-pan mode.
    var accessibilityHint: Text {
        return switch self {
        case .off:
            Text(
                "Turn off auto-pan",
                bundle: .toolkitModule,
                comment: "The accessibility hint for turning the auto-pan mode off in the location button context menu."
            )
        case .recenter:
            Text(
                "Change auto-pan mode to recenter",
                bundle: .toolkitModule,
                comment: "The accessibility hint for choosing the 'recenter' auto-pan mode in the location button context menu."
            )
        case .compassNavigation:
            Text(
                "Change auto-pan mode to compass",
                bundle: .toolkitModule,
                comment: "The accessibility hint for choosing the 'compass navigation' auto-pan mode in the location button context menu."
            )
        case .navigation:
            Text(
                "Change auto-pan mode to navigation",
                bundle: .toolkitModule,
                comment: "The accessibility hint for choosing the 'navigation' auto-pan mode in the location button context menu."
            )
        @unknown default:
            fatalError()
        }
    }
    
    /// The image associated with the auto-pan mode.
    var imageSystemName: String {
        switch self {
        case .compassNavigation:
            "location.north.line.fill"
        case .navigation:
            "location.north.fill"
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
    @Previewable @State var map = Map(basemap: .init(baseLayer: OpenStreetMapLayer()))
    @Previewable @State var locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    
    MapView(map: map)
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
