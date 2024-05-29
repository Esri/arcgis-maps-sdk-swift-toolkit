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

***REMOVED***/ The state of importing a new attachment.
enum AttachmentImportState: Equatable {
***REMOVED***case none
***REMOVED***case importing
***REMOVED***case finalizing(AttachmentImportData)
***REMOVED***case errored(AttachmentImportError)
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if a new attachment is being imported.
***REMOVED***var importInProgress: Bool {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .importing, .finalizing(_):
***REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if an error was encountered when importing the last attachment.
***REMOVED***var isErrored: Bool {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .errored(_):
***REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***false
***REMOVED***
***REMOVED***
***REMOVED***
