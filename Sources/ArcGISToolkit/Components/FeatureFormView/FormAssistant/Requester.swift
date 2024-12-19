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

import Foundation
import UIKit.UIImage

enum OpenAIModel: String {
***REMOVED***case fourO = "gpt-4o"
***REMOVED***

***REMOVED***/ [Low or high fidelity image understanding](https:***REMOVED***platform.openai.com/docs/guides/vision#low-or-high-fidelity-image-understanding)
enum OpenAIVisionDetail: String {
***REMOVED***case auto = "auto"
***REMOVED***case high = "high"
***REMOVED***case low = "low"
***REMOVED***

class Requester {
***REMOVED***let model = OpenAIModel.fourO
***REMOVED***
***REMOVED***func makeImageRequest(_ image: UIImage, compression: CGFloat = 1.0, detail: OpenAIVisionDetail = .auto) async -> String {
***REMOVED******REMOVED***guard let data = image.jpegData(compressionQuality: compression)?.base64EncodedString() else {
***REMOVED******REMOVED******REMOVED***return "Error - No b64 data"
***REMOVED***
***REMOVED******REMOVED***let json: [String: Any] = [
***REMOVED******REMOVED******REMOVED***"model": model.rawValue,
***REMOVED******REMOVED******REMOVED***"messages": [
***REMOVED******REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"role": "user",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"content": [
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"type": "text",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"text": "What's in this image?"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"type": "image_url",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"image_url": [
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"url": "data:image/jpeg;base64,\(data)\"",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"detail": "low"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***]
***REMOVED******REMOVED***return await makeRequest(json: json)
***REMOVED***
***REMOVED***
***REMOVED***func makeTextRequest(request: String? = nil) async -> String {
***REMOVED******REMOVED***let _request = request ?? "write a haiku about ai"
***REMOVED******REMOVED***let json: [String: Any] = [
***REMOVED******REMOVED******REMOVED***"model": model.rawValue,
***REMOVED******REMOVED******REMOVED***"messages": [
***REMOVED******REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"role": "user",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"content": _request
***REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***]
***REMOVED******REMOVED***return await makeRequest(json: json)
***REMOVED***
***REMOVED***
***REMOVED***func makeRequest(json: [String: Any]) async -> String {
***REMOVED******REMOVED***guard let key: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
***REMOVED******REMOVED******REMOVED***return "Error - NO API KEY FOUND"
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var request = URLRequest(url: URL.OPENAI_COMPLETION_API_URL)
***REMOVED******REMOVED***request.httpMethod = "POST"
***REMOVED******REMOVED***request.setValue("application/json", forHTTPHeaderField: "Content-Type")
***REMOVED******REMOVED***request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let jsonData = try? JSONSerialization.data(withJSONObject: json)
***REMOVED******REMOVED***
***REMOVED******REMOVED***request.httpBody = jsonData
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let (data, _) = try await URLSession.shared.data(for: request)
***REMOVED******REMOVED******REMOVED***let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
***REMOVED******REMOVED******REMOVED***let choices = jsonResponse?["choices"] as? [[String: Any]]
***REMOVED******REMOVED******REMOVED***let choiceMessage = (choices?.first?["message"] as? [String: Any])?["content"] as? String ?? "No message"
***REMOVED******REMOVED******REMOVED***return choiceMessage
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***return "Error - \(error.localizedDescription)"
***REMOVED***
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static let OPENAI_COMPLETION_API_URL = URL(string: "https:***REMOVED***api.openai.com/v1/chat/completions")!
***REMOVED***
