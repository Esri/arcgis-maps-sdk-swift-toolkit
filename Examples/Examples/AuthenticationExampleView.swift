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

private extension URL {
    static let worldImageryMapServer = URL(string: "https://ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer")!
}

struct AuthenticationExampleView: View {
    @State private var mapLoadResult: Result<Map, Error>?
    //@StateObject private var authenticator = Authenticator()
    
    static func makeMap() -> Map {
        let basemap = Basemap(baseLayer: ArcGISTiledLayer(url: .worldImageryMapServer))
        return Map(basemap: basemap)
    }
    
    var body: some View {
        Group {
            if let mapLoadResult = mapLoadResult {
                switch mapLoadResult {
                case .success(let value):
                    MapView(map: value)
                case .failure(let error):
                    Text("Error loading map: \(errorString(for: error))")
                        .padding()
                }
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                let map = Self.makeMap()
                try await map.load()
                mapLoadResult = .success(map)
            } catch {
                mapLoadResult = .failure(error)
            }
        }
//        .sheet(isPresented: authenticator) {
//            SignInSheet(model: signInModel)
//        }
//        .onAppear {
//            ArcGISURLSession.challengeHandler = signInModel
//        }
//        .onDisappear {
//            ArcGISURLSession.challengeHandler = nil
//        }
    }
    
    private func errorString(for error: Error) -> String {
        switch error {
        case let authenticationError as ArcGISAuthenticationChallenge.Error:
            switch authenticationError {
            case .userCancelled(_):
                return "User cancelled error"
            case .credentialCannotBeShared:
                return "Provided credential cannot be shared"
            }
        default:
            return error.localizedDescription
        }
    }
}

struct AuthenticationExampleView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationExampleView()
    }
}
