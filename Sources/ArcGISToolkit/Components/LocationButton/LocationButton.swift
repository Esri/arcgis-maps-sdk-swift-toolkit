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

public struct LocationButton: View {
***REMOVED***@State var locationDisplay: LocationDisplay
***REMOVED***@State private var status: LocationDataSource.Status = .stopped
***REMOVED***@State private var autoPanMode: LocationDisplay.AutoPanMode = .off
***REMOVED***@State private var lastSelectedAutoPanMode: LocationDisplay.AutoPanMode?
***REMOVED***
***REMOVED***public init(locationDisplay: LocationDisplay) {
***REMOVED******REMOVED***self.locationDisplay = locationDisplay
***REMOVED******REMOVED***self.autoPanMode = locationDisplay.autoPanMode
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***switch status {
***REMOVED******REMOVED******REMOVED***case .stopped, .failedToStart:
***REMOVED******REMOVED******REMOVED******REMOVED***if locationDisplay.dataSource is SystemLocationDataSource,
***REMOVED******REMOVED******REMOVED******REMOVED***   CLLocationManager.shared.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CLLocationManager.shared.requestWhenInUseAuthorization()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await locationDisplay.dataSource.start()
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Error starting location display: \(error)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED******REMOVED***switch autoPanMode {
***REMOVED******REMOVED******REMOVED******REMOVED***case .compassNavigation, .navigation, .recenter:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = .off
***REMOVED******REMOVED******REMOVED******REMOVED***case .off:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let lastSelectedAutoPanMode, lastSelectedAutoPanMode != .off {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = lastSelectedAutoPanMode
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = .recenter
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .starting, .stopping:
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***switch status {
***REMOVED******REMOVED******REMOVED******REMOVED***case .stopped:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.slash")
***REMOVED******REMOVED******REMOVED******REMOVED***case .starting, .stopping:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch autoPanMode {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .compassNavigation:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.north.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .navigation:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.north.line.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .recenter:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .off:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "location")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .failedToStart:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.triangle")
***REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.contextMenu(
***REMOVED******REMOVED******REMOVED***ContextMenu {
***REMOVED******REMOVED******REMOVED******REMOVED***if status == .started {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section("Autopan") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker("Autopan", selection: $autoPanMode) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Autopan Off").tag(LocationDisplay.AutoPanMode.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Recenter").tag(LocationDisplay.AutoPanMode.recenter)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Compass").tag(LocationDisplay.AutoPanMode.compassNavigation)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Navigation").tag(LocationDisplay.AutoPanMode.navigation)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await locationDisplay.dataSource.stop()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Stop Location", systemImage: "location.slash")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.disabled(status == .starting || status == .stopping)
***REMOVED******REMOVED***.onReceive(locationDisplay.dataSource.$status) { status = $0 ***REMOVED***
***REMOVED******REMOVED***.onReceive(locationDisplay.$autoPanMode) { autoPanMode = $0 ***REMOVED***
***REMOVED******REMOVED***.onChange(of: autoPanMode) { _, autoPanMode in
***REMOVED******REMOVED******REMOVED***if autoPanMode != locationDisplay.autoPanMode {
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay.autoPanMode = autoPanMode
***REMOVED******REMOVED******REMOVED******REMOVED***if autoPanMode != .off {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastSelectedAutoPanMode = autoPanMode
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

@MainActor
private extension CLLocationManager {
***REMOVED***static let shared = CLLocationManager()
***REMOVED***

#Preview {
***REMOVED***LocationButton(locationDisplay: LocationDisplay(dataSource: SystemLocationDataSource()))
***REMOVED***
