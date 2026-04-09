// Copyright 2026 Esri
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

import ArcGIS
import FoundationModels

private import os

extension EmbeddedFeatureFormView {
    class LanguageModelAdapter {
        weak var formModel: EmbeddedFeatureFormViewModel?
        
        @available(iOS 26.0, *)
        @Generable
        struct FeatureFormResponse {
            // A property the model uses for reasoning.
            var reasoningSteps: String
            
            @Guide(description: "The answers for each question.")
            var answer: [FieldFormElementResponse]
        }
        
        @available(iOS 26.0, *)
        @Generable
        struct FieldFormElementResponse {
            @Guide(description: "The original question.")
            var question: String
            
            @Guide(description: "The answer to the question.")
            var answer: String
        }
        
        @available(iOS 26.0, *)
        @MainActor
        func generateResponse(observation: String) async throws -> FeatureFormResponse? {
            print("Building Questions")
            
            guard let questions: String = formModel?.featureForm.elements.enumerated().map({ (ix, element) in
                switch element {
                case let element as FieldFormElement:
                    """
                    Question \(ix): \(element.label)
                    """
                case is GroupFormElement: // case let groupElement as GroupFormElement:
                    ""
                default:
                    ""
                }
            }).joined(separator: "\n") else { return nil }
            
            print("Questions: \n\(questions)")
            
            let instructions = """
                You are a helpful assistant translating verbal observations into 
                form answers.
                
                Process the verbal observation and generate an answer for each question.
                """
            
            let session = LanguageModelSession(instructions: instructions)
            
            let prompt = """
                The questions are:
                \(questions)
                
                
                The verbal observation was:
                \(observation)
                """
            
            Logger.featureFormView.info("""
                \(String(describing: self))
                \(prompt)
                """)
            
            let response = try await session.respond(
                to: prompt,
                generating: FeatureFormResponse.self
            )
            return response.content
        }
    }
}
