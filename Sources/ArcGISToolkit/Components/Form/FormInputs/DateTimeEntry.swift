***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import FormsPlugin
***REMOVED***

struct DateTimeEntry: View {
***REMOVED***let element: FieldFeatureFormElement
***REMOVED***
***REMOVED***let input: DateTimePickerFeatureFormInput
***REMOVED***
***REMOVED***@State private var date = Date.now
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if let min = input.min, let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(element.label, selection: $date, in: min...max, displayedComponents: displayedComponents)
***REMOVED*** else if let min = input.min {
***REMOVED******REMOVED******REMOVED***DatePicker(element.label, selection: $date, in: min..., displayedComponents: displayedComponents)
***REMOVED*** else if let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(element.label, selection: $date, in: ...max, displayedComponents: displayedComponents)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***DatePicker(element.label, selection: $date, displayedComponents: displayedComponents)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var displayedComponents: DatePicker.Components {
***REMOVED******REMOVED***input.includeTime ? [.date, .hourAndMinute] : [.date]
***REMOVED***
***REMOVED***
