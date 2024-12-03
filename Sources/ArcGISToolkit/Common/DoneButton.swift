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

struct DoneButton: View {
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED***init(action: (() -> Void)? = nil) {
***REMOVED******REMOVED***self.action = action
***REMOVED***
***REMOVED***
***REMOVED***let action: (() -> Void)?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button(String.done, systemImage: "xmark.circle.fill") {
***REMOVED******REMOVED******REMOVED***action?() ?? dismiss()
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED***.symbolRenderingMode(.hierarchical)
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
#Preview {
***REMOVED***@Previewable @State var isPresented = true
***REMOVED***LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***if !isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DoneButton()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationBackgroundInteraction(.disabled)
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED***
***REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED***
