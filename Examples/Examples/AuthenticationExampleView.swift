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
import ArcGISToolkit

struct AuthenticationExampleView: View {
    @StateObject var authenticator = Authenticator()
    @State var previousApiKey: APIKey?
    
    var body: some View {
        List(AuthenticationItem.all, id: \.title) { item in
            AuthenticationItemView(item: item)
        }
        .navigationBarTitle(Text("Authentication"), displayMode: .inline)
        .sheet(item: $authenticator.continuation) {
            AuthenticationView(continuation: $0)
        }.onAppear {
            ArcGISURLSession.challengeHandler = authenticator
        }
        .onAppear {
            // Save off the api key
            previousApiKey = ArcGISRuntimeEnvironment.apiKey
            // Set the api key to nil so that the authenticated services will prompt.
            ArcGISRuntimeEnvironment.apiKey = nil
        }
        .onDisappear {
            // Restore api key when exiting this example.
            ArcGISRuntimeEnvironment.apiKey = previousApiKey
        }
    }
    
    private func errorString(for error: Error) -> String {
        switch error {
        case is ArcGISAuthenticationChallenge.Error:
            return "Authentication error"
        default:
            return error.localizedDescription
        }
    }
}

private struct AuthenticationItemView: View {
    let loadable: Loadable
    let title: String
    @State var status = LoadStatus.notLoaded
    
    init(item: AuthenticationItem) {
        self.loadable = item.loadable
        self.title = item.title
    }
    
    var body: some View {
        Button {
            Task {
                status = .loading
                try? await loadable.load()
                status = loadable.loadStatus
            }
        } label: {
            buttonContent
        }
    }
    
    var buttonContent: some View {
        HStack {
            Text(title)
            Spacer()
            switch status {
            case .loading:
                ProgressView()
            case .loaded:
                Text("Loaded")
                    .foregroundColor(.green)
            case .notLoaded:
                Text("Tap to load")
                    .foregroundColor(.secondary)
            case .failed:
                Text("Failed to laod")
                    .foregroundColor(.red)
            }
        }
    }
}

private extension URL {
    static let worldImageryMapServer = URL(string: "https://ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer")!
}

private struct AuthenticationItem {
    let title: String
    let loadable: Loadable
}

extension AuthenticationItem {
    static let token = AuthenticationItem(
        title: "Token secured resource",
        loadable: ArcGISTiledLayer(url: .worldImageryMapServer)
    )
    
    static let all: [AuthenticationItem] = [
        .token
    ]
}
