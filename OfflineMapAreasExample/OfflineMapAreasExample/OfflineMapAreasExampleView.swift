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
***REMOVED***Toolkit
***REMOVED***
import UserNotifications

@MainActor
struct OfflineMapAreasExampleView: View {
***REMOVED******REMOVED***/ The map of the Naperville water network.
***REMOVED***@State private var onlineMap = Map(item: PortalItem.naperville())
***REMOVED***
***REMOVED******REMOVED***/ The selected map.
***REMOVED***@State private var selectedOfflineMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the offline map ares view should be presented.
***REMOVED***@State private var isShowingOfflineMapAreasView = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapView(map: selectedOfflineMap ?? onlineMap)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle("Offline Example")
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Menu("Menu") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Go Online") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedOfflineMap = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedOfflineMap == nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Offline Maps") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingOfflineMapAreasView = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isShowingOfflineMapAreasView) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OfflineMapAreasView(onlineMap: onlineMap, selection: $selectedOfflineMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task { await requestUserNotificationAuthorization() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Requests authorization to show notifications.
***REMOVED***private func requestUserNotificationAuthorization() async {
***REMOVED******REMOVED***_ = try? await UNUserNotificationCenter.current()
***REMOVED******REMOVED******REMOVED***.requestAuthorization(options: [.alert, .sound])
***REMOVED***
***REMOVED***

private extension PortalItem {
***REMOVED***static func naperville() -> PortalItem {
***REMOVED******REMOVED***PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED******REMOVED******REMOVED***id: PortalItem.ID("3da658f2492f4cfd8494970ef489d2c5")!
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
