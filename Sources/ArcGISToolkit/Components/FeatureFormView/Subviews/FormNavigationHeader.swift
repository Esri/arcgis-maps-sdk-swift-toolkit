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

***REMOVED***/ <#Description#>
struct FormNavigationHeader: ViewModifier {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@Binding var path: NavigationPath
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let subtitle: String?
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let visibility: Visibility
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content 
***REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden()
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***if visibility != .hidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigation) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !path.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.removeLast()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Label(:systemImage:) does not work properly
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** here so we use an Image only.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.left")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let subtitle {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func formNavigationHeader(
***REMOVED******REMOVED***path: Binding<NavigationPath>,
***REMOVED******REMOVED***visibility: Visibility,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***subtitle: String? = nil
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***FormNavigationHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***path: path,
***REMOVED******REMOVED******REMOVED******REMOVED***subtitle: subtitle,
***REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED***visibility: visibility
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
#Preview {
***REMOVED***@Previewable @State var path = NavigationPath()
***REMOVED***NavigationStack(path: $path) {
***REMOVED******REMOVED***List(1..<4) {
***REMOVED******REMOVED******REMOVED***NavigationLink($0.formatted(), value: $0)
***REMOVED***
***REMOVED******REMOVED***.formNavigationHeader(path: $path, visibility: .visible, title: "Numbers")
***REMOVED******REMOVED***.navigationDestination(for: Int.self) {
***REMOVED******REMOVED******REMOVED***Text($0.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED***.formNavigationHeader(path: $path, visibility: .visible, title: "Number \($0)", subtitle: "Details")
***REMOVED***
***REMOVED***
***REMOVED***
