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

***REMOVED***

public extension View {
***REMOVED******REMOVED***/ Adds an action to perform when this view detects data emitted by the
***REMOVED******REMOVED***/ given async sequence. If `action` is `nil`, then the async sequence is not observed.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sequence: The async sequence to observe.
***REMOVED******REMOVED***/   - value: A value that, when changed, the `action` closure will be re-captured.
***REMOVED******REMOVED***/   - action: The action to perform when a value is emitted by `sequence`.
***REMOVED******REMOVED***/   The value emitted by `sequence` is passed as a parameter to `action`.
***REMOVED******REMOVED***/ - Returns: A view that triggers `action` when `sequence` emits a value.
***REMOVED***@MainActor @ViewBuilder func onReceive<S, E>(
***REMOVED******REMOVED***_ sequence: S,
***REMOVED******REMOVED***id value: E,
***REMOVED******REMOVED***perform action: (@MainActor (S.Element) -> Void)?
***REMOVED***) -> some View where S: AsyncSequence & Sendable, E: Swift.Equatable, S.Element: Sendable {
***REMOVED******REMOVED***if let action = action {
***REMOVED******REMOVED******REMOVED***task(id: value) {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for try await element in sequence {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Adds an action to perform when this view detects data emitted by the
***REMOVED******REMOVED***/ given async sequence. If `action` is `nil`, then the async sequence is not observed.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sequence: The async sequence to observe.
***REMOVED******REMOVED***/   - value: A value that, when changed, the `action` closure will be re-captured.
***REMOVED******REMOVED***/   - action: The action to perform when a value is emitted by `sequence`.
***REMOVED******REMOVED***/   The tuple value emitted by `sequence` is destructured and passed as individual parameters
***REMOVED******REMOVED***/   to `action`.
***REMOVED******REMOVED***/ - Returns: A view that triggers `action` when `sequence` emits a value.
***REMOVED***@MainActor @ViewBuilder func onReceive<S, U, V, E>(
***REMOVED******REMOVED***_ sequence: S,
***REMOVED******REMOVED***id value: E,
***REMOVED******REMOVED***perform action: (@MainActor (U, V) -> Void)?
***REMOVED***) -> some View where S: AsyncSequence & Sendable, S.Element == (U, V), E: Swift.Equatable, S.Element: Sendable {
***REMOVED******REMOVED***if let action = action {
***REMOVED******REMOVED******REMOVED***task(id: value) {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for try await element in sequence {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(element.0, element.1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Adds an action to perform when this view detects data emitted by the
***REMOVED******REMOVED***/ given async sequence. If `action` is `nil`, then the async sequence is not observed.
***REMOVED******REMOVED***/ The `action` closure is captured the first time the view appears.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sequence: The async sequence to observe.
***REMOVED******REMOVED***/   - action: The action to perform when a value is emitted by `sequence`.
***REMOVED******REMOVED***/   The value emitted by `sequence` is passed as a parameter to `action`.
***REMOVED******REMOVED***/ - Returns: A view that triggers `action` when `sequence` emits a value.
***REMOVED***@MainActor @ViewBuilder func onReceive<S>(
***REMOVED******REMOVED***_ sequence: S,
***REMOVED******REMOVED***perform action: (@MainActor (S.Element) -> Void)?
***REMOVED***) -> some View where S: AsyncSequence & Sendable, S.Element: Sendable {
***REMOVED******REMOVED***if let action = action {
***REMOVED******REMOVED******REMOVED***task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for try await element in sequence {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
