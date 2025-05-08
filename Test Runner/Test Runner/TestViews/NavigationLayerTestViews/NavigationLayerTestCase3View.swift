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

***REMOVED***/ A view using NavigationLayer where the current presented item is tracked with
***REMOVED***/ `onNavigationPathChanged(perform:)`.
struct NavigationLayerTestCase3View: View {
***REMOVED***@State private var presentedViewType: String?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationLayer { model in
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Present a view") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DemoView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** footer: {
***REMOVED******REMOVED******REMOVED***Text(presentedViewType ?? "Root view")
***REMOVED***
***REMOVED******REMOVED***.onNavigationPathChanged { item in
***REMOVED******REMOVED******REMOVED***if let item {
***REMOVED******REMOVED******REMOVED******REMOVED***presentedViewType = "\(type(of: item.view()))"
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***presentedViewType = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension NavigationLayerTestCase3View {
***REMOVED***struct DemoView: View {
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List { ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
