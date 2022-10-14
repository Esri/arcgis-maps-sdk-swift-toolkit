// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import Combine

/// A view displaying an async image, with error display and progress view.
struct AsyncImageView: View {
    /// The `URL` of the image.
    let url: URL
    
    var imageURL: URL
    
    /// The `ContentMode` defining how the image fills the available space.
    let contentMode: ContentMode
    
    /// The `ContentMode` defining how the image fills the available space.
    let refreshInterval: UInt64
    
//    @State var timer: Timer?
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>

    @State var refreshing: Bool = false
    
    @State var currentImage: Image?
    
    /// Creates an `AsyncImageView`.
    /// - Parameters:
    ///   - url: The `URL` of the image.
    ///   - contentMode: The `ContentMode` defining how the image fills the available space.
    ///   - refreshInterval: The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
    public init(url: URL, contentMode: ContentMode = .fit, refreshInterval: UInt64 = 0) {
        self.url = url
        self.imageURL = url
        self.contentMode = contentMode
        self.refreshInterval = refreshInterval
        print("self.refreshInterval = \(self.refreshInterval)")
        let interval = refreshInterval > 0 ? Double(refreshInterval) / 1000 : TimeInterval.greatestFiniteMagnitude
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }
    
    var body: some View {
        ZStack {
            // Display the current image behind the AsyncImage so when the
            // AsyncImage is refreshing we don't get a white background with
            // just the progress view.
            if let currentImage {
                currentImage
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
            AsyncImage(url: refreshing ? nil : imageURL) { phase in
                if let image = phase.image {
                    // Displays the loaded image.
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .task(id: refreshing) {
                            print("ImageDrawing, refreshing = \(refreshing)")
                            refreshing = false
                            currentImage = image
                        }
                } else if phase.error != nil, !refreshing {
                    // Displays an error notification.
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.circle")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                        Text("An error occurred loading the image.")
                    }
                    .padding([.top, .bottom])
                } else {
                    // Display the progress view until image loads.
                    ProgressView()
                }
            }
        }
        .onReceive(timer) { _ in
            if !refreshing, currentImage != nil {
                print("Timer fired, refreshing = \(refreshing)")
                refreshing = true
            }
        }
        .onAppear() {
//            if refreshInterval > 0 {
//                timer = Timer.scheduledTimer(
//                    withTimeInterval: Double(refreshInterval) / 1000,
//                    repeats: true,
//                    block: { timer in
//                        if !refreshing {
//                            print("Timer fired, refreshing = \(refreshing)")
//                            refreshing = true
//                        }
//                    })
//            }
        }
        .onDisappear() {
//            timer?.invalidate()
        }
    }
}
