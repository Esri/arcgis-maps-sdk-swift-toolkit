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

***REMOVED***/ A view to display grouped content together within a ScrollView.
struct FeatureFormGroupedContentView<Content: View>: View {
***REMOVED***let content: [Content]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***ForEach(content.enumerated().map({ ($0.offset, $0.element) ***REMOVED***), id: \.0) { (offset, content) in
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***if offset+1 != self.content.count {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED***.formInputStyle()
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***ScrollView {
***REMOVED******REMOVED***FeatureFormGroupedContentView(content: [
***REMOVED******REMOVED******REMOVED***Button { ***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("A Button")
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED***
***REMOVED******REMOVED***])
***REMOVED******REMOVED***
***REMOVED******REMOVED***FeatureFormGroupedContentView(content: [
***REMOVED******REMOVED******REMOVED***Text("Text 1"), Text("Text 2")
***REMOVED******REMOVED***])
***REMOVED******REMOVED***
***REMOVED******REMOVED***FeatureFormGroupedContentView(content: [
***REMOVED******REMOVED******REMOVED***NavigationLink("Navigation Link 1", value: 1),
***REMOVED******REMOVED******REMOVED***NavigationLink("Navigation Link 2", value: 2),
***REMOVED******REMOVED******REMOVED***NavigationLink("Navigation Link 3", value: 3)
***REMOVED******REMOVED***])
***REMOVED***
***REMOVED***
