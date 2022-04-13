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

***REMOVED***/ A view which allows selection of levels represented in `FloorFacility`.
struct LevelSelector: View {
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating the whether the view shows only the selected level or all levels.
***REMOVED******REMOVED***/ If the value is`false`, the view will display all levels; if it is `true`, the view will only display
***REMOVED******REMOVED***/ the selected level.
***REMOVED***@Binding var isCollapsed: Bool
***REMOVED***
***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]
***REMOVED***
***REMOVED******REMOVED***/ Returns the short name of the currently selected level, the first level or "None" if none of the listed
***REMOVED******REMOVED***/ are available.
***REMOVED***private var selectedLevelName: String {
***REMOVED******REMOVED***viewModel.selectedLevel?.shortName ?? ""
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***var isTopAligned: Bool
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if !isCollapsed,
***REMOVED******REMOVED******REMOVED***levels.count > 1 {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if !isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***LevelsStack(levels: levels)
***REMOVED******REMOVED******REMOVED******REMOVED***if isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Toggle(isOn: $isCollapsed) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedLevelName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toggleStyle(.button)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A vertical list of floor levels.
struct LevelsStack: View {
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State private var contentHeight: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(levels) { level in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isOn: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectedLevel == level
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { newIsOn in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard newIsOn else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(level.shortName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toggleStyle(.button)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***contentHeight = $0.height
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(maxHeight: contentHeight)
***REMOVED***
***REMOVED***

***REMOVED***/ A button used to collapse the floor level list.
struct CollapseButton: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding var isCollapsed: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark")
***REMOVED***
***REMOVED******REMOVED***.padding(EdgeInsets(
***REMOVED******REMOVED******REMOVED***top: 2,
***REMOVED******REMOVED******REMOVED***leading: 4,
***REMOVED******REMOVED******REMOVED***bottom: 2,
***REMOVED******REMOVED******REMOVED***trailing: 4
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
