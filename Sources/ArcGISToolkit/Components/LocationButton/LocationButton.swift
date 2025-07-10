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
    /// The model backing this view.
    @State private var model: Model
    
    /// The auto-pan options available for the user to set.
    private var autoPanOptions: [LocationDisplay.AutoPanMode] = [
        .recenter, .compassNavigation, .navigation, .off
    ]
    
    /// Creates a location button with a location display.
    /// - Parameter locationDisplay: The location display that the button will control.
    public init(locationDisplay: LocationDisplay) {
        model = Model(locationDisplay: locationDisplay)
    }
    
    /// Sets the auto-pan options that are available for the user to select.
    /// - Parameter options: The auto-pan options that the user can cycle through.
    /// - Returns: A new location button with the auto-pan options set.
    public func autoPanOptions(_ options: [LocationDisplay.AutoPanMode]) -> Self {
        var copy = self
        copy.autoPanOptions = options
        return copy
    }
    
    public var body: some View {
        Button {
            model.buttonAction()
        } label: {
            buttonLabel()
                .padding(8)
        }
        .onChange(of: autoPanOptions, initial: true) { model.autoPanOptions = autoPanOptions }
        .contextMenu(ContextMenu { contextMenuContent() })
        .disabled(model.buttonIsDisabled)
        .task { await model.observeStatus() }
        .task { await model.observeAutoPanMode() }
        .animation(.default, value: model.autoPanMode)
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
        // Only show context menu if non-off autopan options are not empty and the
        // status of the location display is started.
        if !model.nonOffAutoPanOptions.isEmpty && model.status == .started {
            Section("Autopan") {
                ForEach(model.contextMenuAutoPanOptions, id: \.self) { autoPanMode in
                    Button {
                        model.select(autoPanMode: autoPanMode)
                    } label: {
                        Label(autoPanMode.pickerText, systemImage: autoPanMode.imageSystemName)
                    }
                }
            }
            
            Button {
                Task {
                    await model.hideLocationDisplay()
                }
            } label: {
                Label("Hide Location", systemImage: "location.slash")
            }
        }
    }
}

extension LocationButton {
    /// The model for the location button.
    @MainActor
    @Observable
    class Model {
        /// The location display which the button controls.
        let locationDisplay: LocationDisplay
        
        /// The current status of the location display's datasource.
        var status: LocationDataSource.Status = .stopped {
            didSet {
                buttonIsDisabled = status == .starting || status == .stopping
            }
        }
        
        /// The autopan mode of the location display.
        private(set) var autoPanMode: LocationDisplay.AutoPanMode = .off
        
        /// A value indicating whether the button is disabled.
        var buttonIsDisabled: Bool = true
        
        /// Backing variable for the auto pan options that are selectable by the user.
        private var _autoPanOptions: [LocationDisplay.AutoPanMode] = []
        
        /// The auto pan options that are selectable by the user.
        var autoPanOptions: [LocationDisplay.AutoPanMode] {
            get { _autoPanOptions }
            set {
                _autoPanOptions = newValue.unique()
                // If current mode not in new options, then switch it out.
                if !_autoPanOptions.contains(autoPanMode) {
                    select(autoPanMode: initialAutoPanMode)
                }
            }
        }
        
        /// The auto-pan options that are not `.off`.
        var nonOffAutoPanOptions: [LocationDisplay.AutoPanMode] {
            autoPanOptions.filter { $0 != .off }
        }
        
        /// The initail auto-pan mode to be used.
        var initialAutoPanMode: LocationDisplay.AutoPanMode {
            autoPanOptions.first ?? .off
        }
        
        /// The context menu auto-pan mode options.
        /// The context menu options will be in the order the user specifies
        /// except the off option will be first.
        var contextMenuAutoPanOptions: [LocationDisplay.AutoPanMode] {
            return if autoPanOptions.contains(.off) {
                [.off] + nonOffAutoPanOptions
            } else {
                autoPanOptions
            }
        }
        
        /// The next auto pan mode to be used when cycling through auto pan modes.
        var nextAutoPanMode: LocationDisplay.AutoPanMode {
            guard let index = autoPanOptions.firstIndex(of: autoPanMode) else { return initialAutoPanMode }
            let nextIndex = index.advanced(by: 1) == autoPanOptions.endIndex ? autoPanOptions.startIndex : index.advanced(by: 1)
            return autoPanOptions[nextIndex]
        }
        
        /// Creates a location button model with a location display.
        /// - Parameter locationDisplay: The location display that the button will control.
        init(
            locationDisplay: LocationDisplay
        ) {
            self.locationDisplay = locationDisplay
            self.autoPanMode = locationDisplay.autoPanMode
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
        
        /// The action that should occur if the button is pressed.
        var actionForButtonPress: ButtonAction? {
            // Decide the button behavior based on the status.
            switch status {
            case .stopped, .failedToStart:
                .start
            case .started:
                if nonOffAutoPanOptions.isEmpty {
                    // If there were no non-off options specified then set it to off
                    // if the status is started.
                    .stop
                } else {
                    .autoPanCycle
                }
            case .starting, .stopping:
                nil
            @unknown default:
                fatalError()
            }
        }
        
        /// This should be called when the button is pressed.
        func buttonAction() {
            switch actionForButtonPress {
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
                select(autoPanMode: nextAutoPanMode)
            case .none:
                return
            }
        }
        
        /// Hides the location display.
        func hideLocationDisplay() async {
            await locationDisplay.dataSource.stop()
        }
    }
}

extension LocationButton.Model {
    /// The type of actions that can take place when the button is pressed.
    enum ButtonAction {
        /// Start the location display.
        case start
        /// Stop the location display.
        case stop
        /// Set the next auto pan mode for cycling through.
        case autoPanCycle
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
    MapView(map: Map.openStreetMap())
        .overlay(alignment: .topTrailing) {
            VStack {
                LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
                    .imageScale(.large)
                    .bold()
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .shadow(radius: 8)
            }
            .padding()
        }
}

private extension Map {
   static func openStreetMap() -> Map {
       Map(basemap: .init(baseLayer: OpenStreetMapLayer()))
    }
}
