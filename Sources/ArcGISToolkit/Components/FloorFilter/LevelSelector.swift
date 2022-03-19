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

***REMOVED******REMOVED***/ A Boolean value indicating the whether the view shows only the selected level or all levels.
***REMOVED******REMOVED***/ If the value is`false`, the view will display all levels; if it is `true`, the view will only display
***REMOVED******REMOVED***/ the selected level.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool

***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State
***REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]

***REMOVED******REMOVED***/ Returns the short name of the currently selected level, the first level or "None" if none of the listed
***REMOVED******REMOVED***/ are available.
***REMOVED***private var selectedLevelName: String {
***REMOVED******REMOVED***if let shortName = viewModel.selectedLevel?.shortName {
***REMOVED******REMOVED******REMOVED***return shortName
***REMOVED*** else if let firstLevelShortName = levels.first?.shortName {
***REMOVED******REMOVED******REMOVED***return firstLevelShortName
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return "None"
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***var topAligned: Bool

***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !isCollapsed,
***REMOVED******REMOVED******REMOVED******REMOVED***levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***if !topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LevelsStack(levels: levels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GeometryReader { geometry -> Color in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewContentHeight = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return .clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: scrollViewContentHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedLevelName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(true)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A vertical list of floor levels.
struct LevelsStack: View {
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]

***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***ForEach(levels) { level in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(level.shortName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(level == viewModel.selectedLevel)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A button used to collapse the floor level list.
struct CollapseButton: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool

***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark")
***REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(
***REMOVED******REMOVED******REMOVED******REMOVED***top: 2,
***REMOVED******REMOVED******REMOVED******REMOVED***leading: 4,
***REMOVED******REMOVED******REMOVED******REMOVED***bottom: 2,
***REMOVED******REMOVED******REMOVED******REMOVED***trailing: 4
***REMOVED******REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
