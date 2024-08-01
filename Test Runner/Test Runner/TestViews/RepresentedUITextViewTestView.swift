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

@testable ***REMOVED***Toolkit
***REMOVED***

struct RepresentedUITextViewTestView: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***NavigationLink("TestInit", destination: TestInit())
***REMOVED******REMOVED******REMOVED***NavigationLink("TestInitWithActions", destination: TestInitWithActions())
***REMOVED***
***REMOVED***
***REMOVED***

extension RepresentedUITextViewTestView {
***REMOVED***struct TestInit: View {
***REMOVED******REMOVED***@State private var text = "World!"
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Bound Value:")
***REMOVED******REMOVED******REMOVED******REMOVED***Text(text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Bound Value")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***RepresentedUITextView(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Text View")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct TestInitWithActions: View {
***REMOVED******REMOVED***@State private var text = "World!"
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var endValue = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED***@FocusState var isFocused
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Bound Value:")
***REMOVED******REMOVED******REMOVED******REMOVED***Text(text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Bound Value")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("End Value:")
***REMOVED******REMOVED******REMOVED******REMOVED***Text(endValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("End Value")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("End Editing") {
***REMOVED******REMOVED******REMOVED******REMOVED***isFocused = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***RepresentedUITextView(initialText: text) { text in
***REMOVED******REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED*** onTextViewDidEndEditing: { text in
***REMOVED******REMOVED******REMOVED******REMOVED***endValue = text
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Text View")
***REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED***
***REMOVED***
***REMOVED***
