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
***REMOVED***

struct FormFooter: View {
***REMOVED******REMOVED***/ The backing feature form.
***REMOVED***let featureForm: FeatureForm
***REMOVED***
***REMOVED******REMOVED***/ The closure to perform when a choice is made.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Note: This property is optional as the modifier providing the closure may not be applied
***REMOVED******REMOVED***/ to the ``FeatureFormView``.
***REMOVED***let formHandlingEventAction: ((FeatureFormView.EditingEvent) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***@Binding var validationErrorVisibility: Visibility
***REMOVED***
***REMOVED******REMOVED***/ An error thrown from finish editing.
***REMOVED***@Binding var finishEditingError: String?
***REMOVED***
***REMOVED***@Environment(\.setAlertContinuation) var setAlertContinuation
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***formHandlingEventAction?(.discardedEdits(willNavigate: false))
***REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .hidden
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Discard",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Discard edits on the feature form."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if featureForm.validationErrors.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await featureForm.finishEditing()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formHandlingEventAction?(.savedEdits(willNavigate: false))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finishEditingError = String(describing: error)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***setAlertContinuation?(false, {***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Save",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Finish editing the feature form."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
