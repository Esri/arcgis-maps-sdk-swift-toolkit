***REMOVED*** Copyright 2023 Esri.
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   http:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

private struct FormScroll: EnvironmentKey {
***REMOVED***static let defaultValue: CGFloat = .zero
***REMOVED***

extension EnvironmentValues {
***REMOVED******REMOVED***/ The vertical scroll position of the top of the form.
***REMOVED***var formScroll: CGFloat {
***REMOVED******REMOVED***get { self[FormScroll.self] ***REMOVED***
***REMOVED******REMOVED***set { self[FormScroll.self] = newValue ***REMOVED***
***REMOVED***
***REMOVED***
