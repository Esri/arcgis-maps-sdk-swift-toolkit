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
***REMOVED***@State private var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the offline map ares view should be presented.
***REMOVED***@State private var isShowingOfflineMapAreasView = false
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight = 0.0
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: selectedMap ?? onlineMap)
***REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged { newHeight in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { attributionBarHeight = newHeight ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED***if selectedMap != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Go Online") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 10 + attributionBarHeight)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .bottomBar) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Offline Maps") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingOfflineMapAreasView = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isShowingOfflineMapAreasView) {
***REMOVED******REMOVED******REMOVED******REMOVED***OfflineMapAreasView(online: onlineMap, selection: $selectedMap)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await requestUserNotificationAuthorization()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
