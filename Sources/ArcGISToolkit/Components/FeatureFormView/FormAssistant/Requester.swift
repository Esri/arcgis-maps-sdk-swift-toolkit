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

import Foundation
import UIKit.UIImage

enum OpenAIModel: String {
    case fourO = "gpt-4o"
}

/// [Low or high fidelity image understanding](https://platform.openai.com/docs/guides/vision#low-or-high-fidelity-image-understanding)
enum OpenAIVisionDetail: String {
    case auto = "auto"
    case high = "high"
    case low = "low"
}

class Requester {
    let model = OpenAIModel.fourO
    
    func makeImageRequest(_ image: UIImage, compression: CGFloat = 1.0, detail: OpenAIVisionDetail = .auto) async -> String {
        guard let data = image.jpegData(compressionQuality: compression)?.base64EncodedString() else {
            return "Error - No b64 data"
        }
        let json: [String: Any] = [
            "model": model.rawValue,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "What's in this image?"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(data)\"",
                                "detail": "low"
                            ]
                        ]
                    ]
                ]
            ]
        ]
        return await makeRequest(json: json)
    }
    
    func makeTextRequest(request: String? = nil) async -> String {
        let _request = request ?? "write a haiku about ai"
        let json: [String: Any] = [
            "model": model.rawValue,
            "messages": [
                [
                    "role": "user",
                    "content": _request
                ]
            ]
        ]
        return await makeRequest(json: json)
    }
    
    func makeRequest(json: [String: Any]) async -> String {
        guard let key: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            return "Error - NO API KEY FOUND"
        }
        
        var request = URLRequest(url: URL.OPENAI_COMPLETION_API_URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = jsonResponse?["choices"] as? [[String: Any]]
            let choiceMessage = (choices?.first?["message"] as? [String: Any])?["content"] as? String ?? "No message"
            return choiceMessage
        } catch {
            return "Error - \(error.localizedDescription)"
        }
    }
}

private extension URL {
    static let OPENAI_COMPLETION_API_URL = URL(string: "https://api.openai.com/v1/chat/completions")!
}
