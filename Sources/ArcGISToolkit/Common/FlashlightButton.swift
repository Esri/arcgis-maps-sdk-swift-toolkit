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

import AVFoundation
***REMOVED***

struct FlashlightButton: View {
***REMOVED***@State private var torchIsOn = false
***REMOVED***
***REMOVED***var device: AVCaptureDevice? {
***REMOVED******REMOVED***.default(for: .video)
***REMOVED***
***REMOVED***
***REMOVED***var hasTorch: Bool {
***REMOVED******REMOVED***device?.hasTorch ?? false
***REMOVED***
***REMOVED***
***REMOVED***var icon: String {
***REMOVED******REMOVED***switch (hasTorch, torchIsOn) {
***REMOVED******REMOVED***case (false, _):
***REMOVED******REMOVED******REMOVED***"flashlight.slash"
***REMOVED******REMOVED***case (_, true):
***REMOVED******REMOVED******REMOVED***"flashlight.on.fill"
***REMOVED******REMOVED***case (_, false):
***REMOVED******REMOVED******REMOVED***"flashlight.off.fill"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***torchIsOn.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: icon)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(torchIsOn ? .white : .black)
***REMOVED******REMOVED******REMOVED******REMOVED***.contentTransition(.interpolate)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.tint)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(Circle())
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.disabled(!hasTorch)
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***torchIsOn = false
***REMOVED***
***REMOVED******REMOVED***.onChange(of: torchIsOn) { isOn in
***REMOVED******REMOVED******REMOVED***try? device?.lockForConfiguration()
***REMOVED******REMOVED******REMOVED***device?.torchMode = isOn ? .on : .off
***REMOVED******REMOVED******REMOVED***device?.unlockForConfiguration()
***REMOVED***
***REMOVED******REMOVED***.torchFeedback(trigger: torchIsOn)
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***FlashlightButton()
***REMOVED***

private extension View {
***REMOVED***@ViewBuilder
***REMOVED***func torchFeedback(trigger: Bool) -> some View {
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***self
***REMOVED******REMOVED******REMOVED******REMOVED***.sensoryFeedback(.selection, trigger: trigger)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
