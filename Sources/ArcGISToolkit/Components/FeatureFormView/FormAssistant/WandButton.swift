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

struct WandButton: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var colors: [Color] = Color.rainbow
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let action: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***action()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "wand.and.sparkles")
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AngularGradient(colors: colors, center: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.linear(duration: 1.0).repeatForever()) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***colors.shuffle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.mask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "wand.and.sparkles")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.wiggleEffect()
***REMOVED***
***REMOVED***

private extension View {
***REMOVED***@ViewBuilder
***REMOVED***func wiggleEffect() -> some View {
***REMOVED******REMOVED***if #available(iOS 18.0, *) {
***REMOVED******REMOVED******REMOVED***self.symbolEffect(.wiggle, options: .repeat(.continuous))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***WandButton {
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***.font(.largeTitle)
***REMOVED***

extension Color {
***REMOVED***static var rainbow: [Self] {
***REMOVED******REMOVED***[.red, .orange, .yellow, .green, .blue, .indigo, .purple]
***REMOVED***
***REMOVED***
