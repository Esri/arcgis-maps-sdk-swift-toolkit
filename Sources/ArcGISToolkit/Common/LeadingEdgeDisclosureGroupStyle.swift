***REMOVED*** Copyright 2025 Esri
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

***REMOVED***/ A disclosure group style that places the disclosure arrow at the leading edge.
***REMOVED***/
***REMOVED***/ Use ``DisclosureGroupStyle/leadingEdge`` to construct this style.
struct LeadingEdgeDisclosureGroupStyle: DisclosureGroupStyle {
***REMOVED***func makeBody(configuration: Configuration) -> some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***configuration.isExpanded.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.animation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.easeInOut(duration: 0.3),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: configuration.isExpanded
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***configuration.label
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED***.alignmentGuide(.listRowSeparatorLeading) { dimensions in
***REMOVED******REMOVED******REMOVED******REMOVED***dimensions[.leading]
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***if configuration.isExpanded {
***REMOVED******REMOVED******REMOVED***configuration.content
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowInsets((.init(top: 0, leading: 50, bottom: 0, trailing: 0)))
***REMOVED***
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***func makeDemoContent() -> some View {
***REMOVED******REMOVED***ForEach(1..<3) {
***REMOVED******REMOVED******REMOVED***Text($0.formatted())
***REMOVED***
***REMOVED***
***REMOVED***return List {
***REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED***DisclosureGroup("\(AutomaticDisclosureGroupStyle.self)") {
***REMOVED******REMOVED******REMOVED******REMOVED***makeDemoContent()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.disclosureGroupStyle(.automatic)
***REMOVED***
***REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED***DisclosureGroup("\(LeadingEdgeDisclosureGroupStyle.self)") {
***REMOVED******REMOVED******REMOVED******REMOVED***makeDemoContent()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.disclosureGroupStyle(.leadingEdge)
***REMOVED***
***REMOVED***
***REMOVED***
