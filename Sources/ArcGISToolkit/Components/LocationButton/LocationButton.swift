***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import CoreLocation
***REMOVED***

***REMOVED***/ A button that allows a user to show their location on a map view.
***REMOVED***/ Gives the user a variety of options to set the auto pan mode or stop the
***REMOVED***/ location datasource.
public struct LocationButton: View {
***REMOVED******REMOVED***/ The location display which the button controls.
***REMOVED***@State private var locationDisplay: LocationDisplay
***REMOVED******REMOVED***/ The current status of the location display's datasource.
***REMOVED***@State private var status: LocationDataSource.Status = .stopped
***REMOVED******REMOVED***/ The autopan mode of the location display.
***REMOVED***@State private var autoPanMode: LocationDisplay.AutoPanMode = .off
***REMOVED******REMOVED***/ The last selected autopan mode by the user.
***REMOVED***@State private var lastSelectedAutoPanMode: LocationDisplay.AutoPanMode
***REMOVED******REMOVED***/ The auto pan options that the user can choose from the context menu of the button.
***REMOVED***private let autoPanOptions: Set<LocationDisplay.AutoPanMode>
***REMOVED***
***REMOVED******REMOVED***/ Creates a location button with a location display.
***REMOVED******REMOVED***/ - Parameter locationDisplay: The location display that the button will control.
***REMOVED***public init(
***REMOVED******REMOVED***locationDisplay: LocationDisplay,
***REMOVED******REMOVED***autoPanOptions: Set<LocationDisplay.AutoPanMode> = [.off, .recenter, .compassNavigation, .navigation]
***REMOVED***) {
***REMOVED******REMOVED***self.locationDisplay = locationDisplay
***REMOVED******REMOVED***self.autoPanMode = locationDisplay.autoPanMode
***REMOVED******REMOVED***self.autoPanOptions = autoPanOptions
***REMOVED******REMOVED***if autoPanOptions.isEmpty || (autoPanOptions.count == 1 && autoPanOptions.first == .off) {
***REMOVED******REMOVED******REMOVED***lastSelectedAutoPanMode = .off
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***lastSelectedAutoPanMode = LocationDisplay.AutoPanMode.orderedOptions
***REMOVED******REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0 != .off ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.first { autoPanOptions.contains($0) ***REMOVED*** ?? .recenter
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***buttonAction()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***buttonLabel()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED***
***REMOVED******REMOVED***.contextMenu(
***REMOVED******REMOVED******REMOVED***ContextMenu { contextMenuContent() ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.disabled(status == .starting || status == .stopping)
***REMOVED******REMOVED***.onReceive(locationDisplay.dataSource.$status) { status = $0 ***REMOVED***
***REMOVED******REMOVED***.onReceive(locationDisplay.$autoPanMode) { autoPanMode = $0 ***REMOVED***
***REMOVED******REMOVED***.onChange(of: autoPanMode) { autoPanMode in
***REMOVED******REMOVED******REMOVED***if autoPanMode != locationDisplay.autoPanMode {
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = autoPanMode
***REMOVED******REMOVED******REMOVED******REMOVED***if autoPanMode != .off {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Do not update the last selected autopan mode here if
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `off` was selected by the user.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastSelectedAutoPanMode = autoPanMode
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***private func buttonAction() {
***REMOVED******REMOVED******REMOVED*** Decide the button behavior based on the status.
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .stopped, .failedToStart:
***REMOVED******REMOVED******REMOVED******REMOVED*** If the datasource is a system location datasource, then request authorization.
***REMOVED******REMOVED******REMOVED***if locationDisplay.dataSource is SystemLocationDataSource,
***REMOVED******REMOVED******REMOVED***   CLLocationManager.shared.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED***CLLocationManager.shared.requestWhenInUseAuthorization()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Start the datasource, set initial auto pan mode.
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = lastSelectedAutoPanMode
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await locationDisplay.dataSource.start()
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Error starting location display: \(error)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED******REMOVED*** If the datasource is started then decide what to do based
***REMOVED******REMOVED******REMOVED******REMOVED*** on the autopan mode.
***REMOVED******REMOVED******REMOVED***switch autoPanMode {
***REMOVED******REMOVED******REMOVED***case .off:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If autopan is off, then set it to the last selected autopan mode.
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = lastSelectedAutoPanMode
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise set it to off.
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = .off
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .starting, .stopping:
***REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***private func buttonLabel() -> some View {
***REMOVED******REMOVED******REMOVED*** Decide what what image is in the button based on the status
***REMOVED******REMOVED******REMOVED*** and autopan mode.
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .stopped:
***REMOVED******REMOVED******REMOVED***Image(systemName: "location.slash")
***REMOVED******REMOVED***case .starting, .stopping:
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED***switch autoPanMode {
***REMOVED******REMOVED******REMOVED***case .compassNavigation:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.north.circle")
***REMOVED******REMOVED******REMOVED***case .navigation:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.north.line.fill")
***REMOVED******REMOVED******REMOVED***case .recenter:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.fill")
***REMOVED******REMOVED******REMOVED***case .off:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location")
***REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failedToStart:
***REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.triangle")
***REMOVED******REMOVED******REMOVED******REMOVED***.tint(.secondary)
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***private func contextMenuContent() -> some View {
***REMOVED******REMOVED***if status == .started {
***REMOVED******REMOVED******REMOVED***if autoPanOptions.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Autopan") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker("Autopan", selection: $autoPanMode) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(LocationDisplay.AutoPanMode.orderedOptions, id: \.self) { autoPanMode in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if autoPanOptions.contains(autoPanMode) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(autoPanMode.pickerText).tag(autoPanMode)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await locationDisplay.dataSource.stop()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Hide Location", systemImage: "location.slash")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension LocationDisplay.AutoPanMode {
***REMOVED******REMOVED***/ The options that will appear in the picker, in order.
***REMOVED***static let orderedOptions: [Self] = [.off, .recenter, .compassNavigation, .navigation]
***REMOVED***
***REMOVED******REMOVED***/ The label that should appear in the picker.
***REMOVED***var pickerText: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .off:
***REMOVED******REMOVED******REMOVED***"Auto Pan Off"
***REMOVED******REMOVED***case .recenter:
***REMOVED******REMOVED******REMOVED***"Recenter"
***REMOVED******REMOVED***case .compassNavigation:
***REMOVED******REMOVED******REMOVED***"Compass"
***REMOVED******REMOVED***case .navigation:
***REMOVED******REMOVED******REMOVED***"Navigation"
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***

@MainActor
private extension CLLocationManager {
***REMOVED***static let shared = CLLocationManager()
***REMOVED***

#Preview {
***REMOVED***MapView(map: Map.openStreetMap())
***REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.thinMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonBorderShape(.circle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(radius: 8)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***

private extension Map {
   static func openStreetMap() -> Map {
***REMOVED***   let map = Map(spatialReference: .webMercator)
***REMOVED***   map.addOperationalLayer(OpenStreetMapLayer())
***REMOVED***   return map
***REMOVED***
***REMOVED***
