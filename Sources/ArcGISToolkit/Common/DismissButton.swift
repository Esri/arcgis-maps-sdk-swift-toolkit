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

struct DismissButton: View {
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED***init(_ label: String? = nil, size: CGFloat? = nil, action: (() -> Void)? = nil) {
***REMOVED******REMOVED***self.action = action
***REMOVED******REMOVED***self.label = label
***REMOVED******REMOVED***if let size {
***REMOVED******REMOVED******REMOVED***self.size = size
***REMOVED*** else {
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***self.size = 20
#else
***REMOVED******REMOVED***self.size = 28
#endif
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***let action: (() -> Void)?
***REMOVED***
***REMOVED***let label: String?
***REMOVED***
***REMOVED***let size: CGFloat
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if let action {
***REMOVED******REMOVED******REMOVED******REMOVED***action()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***if let label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(label)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolRenderingMode(.hierarchical)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: size, height: size)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DismissButton("Done")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DismissButton()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationBackgroundInteraction(.disabled)
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED***
***REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED***
