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

enum ListItem {
***REMOVED***case category(Category)
***REMOVED***case example(Example)
***REMOVED***

extension ListItem: Identifiable {
***REMOVED***var id: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .category(let category):
***REMOVED******REMOVED******REMOVED***return category.id
***REMOVED******REMOVED***case .example(let example):
***REMOVED******REMOVED******REMOVED***return example.id
***REMOVED***
***REMOVED***
***REMOVED***
