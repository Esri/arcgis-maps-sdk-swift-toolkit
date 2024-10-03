// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AVFoundation
import SwiftUI

struct FlashlightButton: View {
    @State private var torchIsOn = false
    
    var device: AVCaptureDevice? {
        .default(for: .video)
    }
    
    var hasTorch: Bool {
        device?.hasTorch ?? false
    }
    
    var body: some View {
        Button {
            torchIsOn.toggle()
        } label: {
            Group {
                if !hasTorch {
                    Image(systemName: "flashlight.slash")
                } else if #available(iOS 17, *) {
                    Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .contentTransition(.symbolEffect(.replace))
                } else {
                    Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(Circle())
        }
        .disabled(!hasTorch)
        .onDisappear {
            torchIsOn = false
        }
        .onChange(of: torchIsOn) { isOn in
            try? device?.lockForConfiguration()
            device?.torchMode = isOn ? .on : .off
            device?.unlockForConfiguration()
        }
    }
}

#Preview {
    FlashlightButton()
}
