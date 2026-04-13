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
        private weak var formModel: EmbeddedFeatureFormViewModel?
        
        @available(iOS 26.0, *)
        @Generable
        struct FeatureFormResponse {
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
        
        init(formModel: EmbeddedFeatureFormViewModel) {
            self.formModel = formModel
        }
        
        @available(iOS 26.0, *)
        @MainActor
        func generateResponse(transcript: String) async throws -> FeatureFormResponse? {
            guard let questions: String = formModel?.visibleElements.enumerated().compactMap({ (index, element) in
                switch element {
                case let element as FieldFormElement:
                    guard element.isEditable else { return nil }
                    var base = """
                    Question \(index+1):
                        Field name: \(element.fieldName)
                        Label: \(element.label)
                    """
                    if !element.description.isEmpty {
                        base.append(
                            """
                            \n\tDescription: \(element.description)
                            """
                        )
                    }
                    if !element.hint.isEmpty {
                        base.append(
                            """
                            \n\tHint: \(element.hint)
                            """
                        )
                    }
                    if !element.codedValues.isEmpty {
                        base.append(
                            """
                            \n\tOptions:
                            """
                        )
                        element.codedValues.enumerated().forEach { (index, codedValue) in
                            if let code = codedValue.code {
                                base.append(
                                    """
                                    \n\t\tOption \(index+1):
                                    \t\t\tName: \(codedValue.name)
                                    \t\t\tCode: \(code)
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
            
            let session = LanguageModelSession(instructions: Self.instructions)
            
            let prompt = """
                The questions are:
                \(questions)
                
                The transcript is:
                \(transcript)
                """
            
            Logger.featureFormView.info("\(prompt, privacy: .sensitive)")
            
            let response = try await session.respond(
                to: prompt,
                generating: FeatureFormResponse.self
            )
            
            logResponse(response.content)
            
            return response.content
        }
        
        @available(iOS 26.0, *)
        func logResponse(_ response: FeatureFormResponse) {
            var message = ""
            response.elementResponses.forEach {
                message.append(
                    """
                    \($0.fieldName)
                        Answered: \($0.answered)
                        Answer: \($0.answer)\n
                    """
                )
            }
            Logger.featureFormView.debug("\(message, privacy: .sensitive)")
        }
        
        /// Instructions fed to the language model to convert the speech transcript to element responses.
        static let instructions = """
            You are a helpful assistant converting a transcript into answers for
            a fillable form.
            
            You may not be able to answer every question with the information in
            the transcript, leave the question unanswered if so.
            
            The transcript may not address the questions in order.
            
            Do not use any information from the question in your answers.
            
            If options are provided for the question and you can make a
            determination of the best option, use the code for the best 
            option as your answer.
            """
    }
}
