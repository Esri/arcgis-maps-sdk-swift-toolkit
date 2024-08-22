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
***REMOVED***

struct TextFormElementView: View {
***REMOVED***let element: TextFormElement
***REMOVED***
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch element.textFormat {
***REMOVED******REMOVED******REMOVED***case .markdown:
***REMOVED******REMOVED******REMOVED******REMOVED***MarkdownView(markdown: text)
***REMOVED******REMOVED******REMOVED***case .plainText:
***REMOVED******REMOVED******REMOVED******REMOVED***Text(text)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***for await text in element.$text {
***REMOVED******REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
