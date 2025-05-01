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

@testable ***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ A view using NavigationLayer where  <#Description#>
struct NavigationLayerTestCase2View: View {
***REMOVED***@State private var alertIsPresented = false
***REMOVED***
***REMOVED***@State private var model: NavigationLayerModel?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationLayer { model in
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Present a view") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Presented view")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***self.model = model
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.backNavigationAction { _ in
***REMOVED******REMOVED******REMOVED***alertIsPresented = true
***REMOVED***
***REMOVED******REMOVED***.alert("Navigation blocked!", isPresented: $alertIsPresented) {
***REMOVED******REMOVED******REMOVED***Button("Continue") {
***REMOVED******REMOVED******REMOVED******REMOVED***model?.pop()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
