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

internal import os

extension EmbeddedFeatureFormView {
    class LanguageModelAdapter {
        private weak var formModel: EmbeddedFeatureFormViewModel?
        
        /// A type-erased language model session.
        ///
        /// Note: This is a temporary backing property for not being able to use the availability attribute on
        /// stored properties. Once iOS 26 is the minimum required OS, this property can be removed.
        private var _session: Any?
        @available(iOS 26.0, *)
        private var session: LanguageModelSession? {
            _session as? LanguageModelSession
        }
        
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
            if #available(iOS 26.0, *) {
                let session = LanguageModelSession(instructions: Self.instructions)
                session.prewarm()
                _session = session
            }
        }
        
        /// A Boolean value indicating whether Foundation Models are available on the current device.
        static public var isAvailable: Bool {
            if #available(iOS 26.0, *) {
                SystemLanguageModel.default.isAvailable
            } else {
                false
            }
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
                        Question: \(element.label)
                        Field name: \(element.fieldName)
                    """
                    if let fieldType = element.fieldType {
                        base.append(
                            """
                            \n\tAnswer Data Type: \(fieldType)
                            """
                        )
                    }
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
                    } else if !(element.fieldType?.isNumeric ?? false), let input = element.input as? TextAreaFormInput {
                        base.append(
                            """
                            \n\tAnswer Length: \(input.minLength)-\(input.maxLength) characters
                            """
                        )
                    } else if !(element.fieldType?.isNumeric ?? false), let input = element.input as? TextBoxFormInput {
                       base.append(
                           """
                           \n\tAnswer Length: \(input.minLength)-\(input.maxLength) characters
                           """
                       )
                    } else if element.fieldType?.isNumeric ?? false, let rangeDomain = element.domain as? RangeDomain {
                        base.append(
                            """
                            \n\tAnswer Range: \(rangeDomain.minValue)-\(rangeDomain.maxValue)
                            """
                        )
                    }
                    return base
                case is GroupFormElement: // case let groupElement as GroupFormElement:
                    return nil
                default:
                    return nil
                }
            }).joined(separator: "\n") else { return nil }
            
            let prompt = """
                The questions are:
                \(questions)
                
                The transcript is:
                \(transcript)
                """
            
            Logger.featureFormView.info("\(prompt, privacy: .sensitive)")
            
            guard let response = try await session?.respond(
                to: prompt,
                generating: FeatureFormResponse.self
            ) else {
                return nil
            }
            
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
            Your task is to convert a transcript into form answers.
            
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
