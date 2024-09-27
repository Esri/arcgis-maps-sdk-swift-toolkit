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
***REMOVED***@Binding var flashIsOn: Bool
***REMOVED***
***REMOVED***var device: AVCaptureDevice? {
***REMOVED******REMOVED***.default(for: .video)
***REMOVED***
***REMOVED***
***REMOVED***var hasTorch: Bool {
***REMOVED******REMOVED***device?.hasTorch ?? false
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***flashIsOn.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if !hasTorch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "flashlight.slash")
***REMOVED******REMOVED******REMOVED*** else if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: flashIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentTransition(.symbolEffect(.replace))
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: flashIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
***REMOVED******REMOVED******REMOVED***.clipShape(Circle())
***REMOVED***
***REMOVED******REMOVED***.disabled(!hasTorch)
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***flashIsOn = false
***REMOVED***
***REMOVED******REMOVED***.onChange(of: flashIsOn) { isOn in
***REMOVED******REMOVED******REMOVED***try? device?.lockForConfiguration()
***REMOVED******REMOVED******REMOVED***device?.torchMode = isOn ? .on : .off
***REMOVED******REMOVED******REMOVED***device?.unlockForConfiguration()
***REMOVED***
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
#Preview {
***REMOVED***@Previewable @State var flashlightIsOn = false
***REMOVED***FlashlightButton(flashIsOn: $flashlightIsOn)
***REMOVED***
