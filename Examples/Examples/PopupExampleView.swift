***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct PopupExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Popups example map. - 4 types: text, media image, media chart, fields list
***REMOVED******REMOVED***let portalItem1 = PortalItem(portal: portal, id: Item.ID(rawValue: "10b79e7ad1944422b87f73da86dcf752")!)

***REMOVED******REMOVED******REMOVED*** Popups example map. - Arcade
***REMOVED******REMOVED******REMOVED***Test Case 3.5 Display popup with expression elements defining media [SDK]
***REMOVED******REMOVED******REMOVED***https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=34752f1d149f4b2db96f7a1637767173
***REMOVED******REMOVED***let portalItem2 = PortalItem(portal: portal, id: Item.ID(rawValue: "34752f1d149f4b2db96f7a1637767173")!)

***REMOVED******REMOVED******REMOVED***Test Case 3.2 Display popup with multiple fields elements [FT-SDK]
***REMOVED******REMOVED******REMOVED***https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=8d75d1dbdb5c4ad5849abb26b783987e  **Modified**
***REMOVED******REMOVED***let portalItem3 = PortalItem(portal: portal, id: Item.ID(rawValue: "8d75d1dbdb5c4ad5849abb26b783987e")!)

***REMOVED******REMOVED******REMOVED***Recreation Map with Attachments.
***REMOVED******REMOVED******REMOVED***https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=2afef81236db4eabbbae357e4f990039
***REMOVED******REMOVED***let portalItem4 = PortalItem(portal: portal, id: Item.ID(rawValue: "2afef81236db4eabbbae357e4f990039")!)

***REMOVED******REMOVED******REMOVED***Recreation Map with Attachments - New
***REMOVED******REMOVED******REMOVED***https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=79c995874bea47d08aab5a2c85120e7f
***REMOVED******REMOVED***let portalItem5 = PortalItem(portal: portal, id: Item.ID(rawValue: "79c995874bea47d08aab5a2c85120e7f")!)

***REMOVED******REMOVED******REMOVED***Attachments
***REMOVED******REMOVED******REMOVED***https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=9e3baeb5dcd4473aa13e0065d7794ca6
***REMOVED******REMOVED***let portalItem6 = PortalItem(portal: portal, id: Item.ID(rawValue: "9e3baeb5dcd4473aa13e0065d7794ca6")!)

***REMOVED******REMOVED***return Map(item: portalItem1)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The map displayed in the map view.
***REMOVED***@StateObject private var map = makeMap()
***REMOVED***
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***@State private var identifyResult: Result<[IdentifyLayerResult], Error>?

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let identifyScreenPoint = identifyScreenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let identifyResult = await Result(awaiting: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  try await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***returnPopupsOnly: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  )
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.identifyResult = identifyResult
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.identifyScreenPoint = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if identifyScreenPoint != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if let identifyResult = identifyResult {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***IdentifyResultView(identifyResult: identifyResult)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: 400)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying the results of an identify operation.
struct IdentifyResultView: View {
***REMOVED***var identifyResult: Result<[IdentifyLayerResult], Error>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***switch identifyResult {
***REMOVED******REMOVED***case .success(let identifyLayerResults):
***REMOVED******REMOVED******REMOVED******REMOVED*** Get the first popup from the first layer result.
***REMOVED******REMOVED******REMOVED***if let popup = identifyLayerResults.first?.popups.first {
***REMOVED******REMOVED******REMOVED******REMOVED***PopupView(popup: popup)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***Text("Identify error: \(error.localizedDescription).")
***REMOVED***
***REMOVED***
***REMOVED***
