***REMOVED*** Copyright 2022 Esri
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
***REMOVED***

***REMOVED***/ A view which allows selection of levels represented in `FloorFacility`.
struct LevelSelector: View {
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State private var contentHeight: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating the whether the view shows only the selected level or all levels.
***REMOVED******REMOVED***/ If the value is`false`, the view will display all levels; if it is `true`, the view will
***REMOVED******REMOVED***/ only display the selected level.
***REMOVED***@State private var isCollapsed: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***let isTopAligned: Bool
***REMOVED***
***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***makeCollapseButton()
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***makeLevelButtons()
***REMOVED******REMOVED******REMOVED***if isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***makeCollapseButton()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension LevelSelector {
***REMOVED******REMOVED***/ A list of all the levels to be displayed.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If the selector is collapsed, only the selected level is shown.
***REMOVED***var filteredLevels: [FloorLevel] {
***REMOVED******REMOVED***if !isCollapsed, levels.count > 1 {
***REMOVED******REMOVED******REMOVED***return levels
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***if let selectedLevel = viewModel.selection?.level {
***REMOVED******REMOVED******REMOVED******REMOVED***return [selectedLevel]
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return []
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The system name of the icon that reflects the current state of `isCollapsed`.
***REMOVED***var iconForCollapsedState: String {
***REMOVED******REMOVED***switch (isCollapsed, isTopAligned) {
***REMOVED******REMOVED***case (true, true), (false, false): return "chevron.down"
***REMOVED******REMOVED***case (true, false), (false, true): return "chevron.up"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button used to collapse the floor level list.
***REMOVED******REMOVED***/ - Returns: The button used to collapse and expand the selector.
***REMOVED***@ViewBuilder func makeCollapseButton() -> some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: iconForCollapsedState)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.toolkitDefault)
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.disabled(levels.count == 1)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button for a level in the floor level list.
***REMOVED******REMOVED***/ - Parameter level: The level represented by the button.
***REMOVED******REMOVED***/ - Returns: The button representing the provided level.
***REMOVED***@ViewBuilder func makeLevelButton(_ level: FloorLevel) -> some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED******REMOVED***if isCollapsed && levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(level.shortName)
***REMOVED***
***REMOVED******REMOVED***.foregroundColor(textColorFor(level))
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
#if os(visionOS)
***REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED***.background(buttonColorFor(level))
***REMOVED******REMOVED***.clipShape(.circle)
#else
***REMOVED******REMOVED***.padding([.vertical], 4)
***REMOVED******REMOVED***.background {
***REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 5)
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(buttonColorFor(level))
***REMOVED***
#endif
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A scrollable list of buttons; one for each level to be displayed.
***REMOVED******REMOVED***/ - Returns: The scrollable list of level buttons.
***REMOVED***@ViewBuilder func makeLevelButtons() -> some View {
***REMOVED******REMOVED***ScrollViewReader { proxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(filteredLevels, id: \.id) { level in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLevelButton(level)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange { contentHeight = $0.height ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxHeight: contentHeight)
***REMOVED******REMOVED******REMOVED***.onAppear { scrollToSelectedLevel(with: proxy) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(isCollapsed) { _ in scrollToSelectedLevel(with: proxy) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines a appropriate color for a button in the floor level list.
***REMOVED******REMOVED***/ - Parameter level: The level represented by the button.
***REMOVED******REMOVED***/ - Returns: The color for the button representing the provided level.
***REMOVED***func buttonColorFor(_ level: FloorLevel) -> Color {
***REMOVED******REMOVED***if viewModel.selection?.level == level {
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***return Color.white
#else
***REMOVED******REMOVED******REMOVED***return Color.accentColor
#endif
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Color.secondary.opacity(0.1)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines a appropriate text color for a button in the floor level list.
***REMOVED******REMOVED***/ - Parameter level: The level represented by the button.
***REMOVED******REMOVED***/ - Returns: The color for the text on the button that is representing the provided level.
***REMOVED***func textColorFor(_ level: FloorLevel) -> Color {
#if os(visionOS)
***REMOVED******REMOVED***if viewModel.selection?.level == level {
***REMOVED******REMOVED******REMOVED******REMOVED*** We need to change the text color on visionOS when a level is selected
***REMOVED******REMOVED******REMOVED******REMOVED*** because the background is now white so the text needs to be black
***REMOVED******REMOVED******REMOVED******REMOVED*** so the text is visible.
***REMOVED******REMOVED******REMOVED***return Color.black
***REMOVED***
#endif
***REMOVED******REMOVED***return Color.primary
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Scrolls the list within the provided proxy to the button representing the selected level.
***REMOVED******REMOVED***/ - Parameter proxy: The proxy containing the scroll view.
***REMOVED***func scrollToSelectedLevel(with proxy: ScrollViewProxy) {
***REMOVED******REMOVED***if let level = viewModel.selection?.level {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***proxy.scrollTo(level.id)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
