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
            /// The answers for each question.
            @Guide(description: "The answers for each question.")
            var elementResponses: [FieldFormElementResponse]
        }
        
        @available(iOS 26.0, *)
        @Generable
        struct FieldFormElementResponse {
            /// The answer to the question.
            @Guide(description: "The answer to the question.")
            var answer: String
            /// Whether the question was answered successfully.
            @Guide(description: "Whether the question was answered successfully.")
            var answered: Bool
            /// The field name of the question.
            @Guide(description: "The field name of the question.")
            var fieldName: String
        }
        
        @available(iOS 26.0, *)
        @MainActor
        func generateResponse(observation: String) async throws -> FeatureFormResponse? {
            guard let questions: String = formModel?.visibleElements.enumerated().compactMap({ (index, element) in
                switch element {
                case let element as FieldFormElement:
                    guard element.isEditable else { return nil }
                    var base = """
                    Question \(index+1):
                        Field name: \(element.fieldName)
                        Label: \(element.label)
                        Description: \(element.description)
                        Hint: \(element.hint)
                    """
                    if !element.codedValues.isEmpty {
                        base.append(
                            """
                            \n\tCoded Values:
                            """
                        )
                        element.codedValues.forEach { codedValue in
                            if let code = codedValue.code {
                                base.append(
                                    """
                                    \n\t\tName: \(codedValue.name) Code: \(code)
                                    """
                                )
                            }
                        }
                    }
                    return base
                case is GroupFormElement: // case let groupElement as GroupFormElement:
                    return nil
                default:
                    return nil
                }
            }).joined(separator: "\n") else { return nil }
            
            let instructions = """
                You are a helpful assistant translating a verbal observation
                into answers for a fillable form.
                
                Use the observation to generate answers for the questions.
                
                You may not be able to answer each question with the given
                observation, leave it unanswered if so.
                
                The observation may not address the questions in order.
                
                Do not use details from the question descriptions as answers.
                
                If insufficient data is provided to answer the question leave it
                blank.
                
                If coded values are provided for the question and you can make a
                determination of the best option, use the code for the best 
                option as your answer.
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
