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
    
    var icon: String {
        switch (hasTorch, torchIsOn) {
        case (false, _):
            "flashlight.slash"
        case (_, true):
            "flashlight.on.fill"
        case (_, false):
            "flashlight.off.fill"
        }
    }
    
    var body: some View {
        Button {
            torchIsOn.toggle()
        } label: {
            Image(systemName: icon)
                .padding()
                .foregroundStyle(torchIsOn ? .white : .black)
                .contentTransition(.interpolate)
                .background(.tint)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
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
