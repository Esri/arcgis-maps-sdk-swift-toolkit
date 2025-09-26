// Copyright 2025 Esri
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
import SwiftUI

extension FeatureFormView {
    /// A view to configure and add a utility network association.
    struct UtilityAssociationCreationView: View {
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// The error to be presented when adding an association failed.
        @State private var addAssociationError: AddAssociationError?
        /// A Boolean value indicating if the alert is presented.
        @State private var alertIsPresented = false
        /// A Boolean value indicating if the content in a containment association is visible.
        ///
        /// See also: `includeContentVisibility`.
        @State private var contentIsVisible: Bool = false
        /// How far along an edge the association is located.
        @State private var fractionAlongEdge: Double = 0.5
        /// The options for a utility network feature when creating an association.
        @State private var options: UtilityAssociationFeatureOptions? = nil
        /// A Boolean value which indicates when the configured association is being added.
        @State private var isAddingAssociation = false
        
        /// The candidate feature for the new association to be created.
        let candidate: UtilityAssociationFeatureCandidate
        /// The element to add the new association to.
        let element: UtilityAssociationsFormElement
        /// The model for the feature form containing the element to add the association to.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        /// The filter to use when creating the association.
        let filter: UtilityAssociationsFilter
        
        var body: some View {
            List {
                sectionForAssociation
                sectionForFromElement
                sectionForToElement
                sectionForFractionAlongEdge
                sectionForAddButton
            }
            .alert(isPresented: $alertIsPresented, error: addAssociationError) {}
            .task {
                options = try? await element.options(forAssociationCandidate: candidate.feature)
            }
            .task(id: isAddingAssociation) {
                guard isAddingAssociation else { return }
                defer { isAddingAssociation = false }
                await addAssociation()
            }
        }
        
        /// Adds the configured association and modifies the navigation path to return the user to the
        /// correct location.
        ///
        /// Upon a successful add, 3 items are removed from the navigation path to return the user to
        /// where the add workflow begins.
        func addAssociation() async {
            guard let options else { return }
            do {
                // TODO: (Ref: Apollo 1368) Use addAssociation(feature:featureTerminal:filter: currentFeatureTerminal:) when neither formFeatureTerminalConfiguration and candidateFeatureTerminalConfiguration are null
                // TODO: (Ref: Apollo 1368) Use addAssociation(feature:filter:fractionAlongEdge:terminal:) when when isFractionAlongEdgeValid AND either formFeatureTerminalConfiguration is set or candidateFeatureTerminalConfiguration is set; but not both.
                if includeContentVisibility {
                    try await element.addAssociation(feature: candidate.feature, filter: filter, isContainmentVisible: contentIsVisible)
                } else if options.isFractionAlongEdgeValid {
                    try await element.addAssociation(feature: candidate.feature, filter: filter, fractionAlongEdge: fractionAlongEdge)
                } else {
                    try await element.addAssociation(feature: candidate.feature, filter: filter)
                }
                // Bug: Path removal is known to fail if the search bar was used
                // in previous views. (FB20395585)
                // https://developer.apple.com/forums/thread/802221#802221021
                navigationPath?.wrappedValue.removeLast(3)
            } catch {
                addAssociationError = .anyError(error)
                alertIsPresented = true
            }
        }
        
        /// A Boolean value indicating whether the candidate feature is on the "to" side of the new association.
        ///
        /// - Note: For connectivity filters, "From" and "To" doesn't have a strong meaning but we
        /// consider the candidate as "To" anyway.
        var candidateIsToElement: Bool {
            switch filter.kind {
            case .attachment, .connectivity, .content:
                true
            case .structure, .container:
                false
            @unknown default:
                true
            }
        }
        
        /// A Boolean value indicating whether content visibility should be specified for the new association.
        var includeContentVisibility: Bool {
            filter.kind == .container || filter.kind == .content
        }
        
        /// A section with a button to add the association.
        var sectionForAddButton: some View {
            Section {
                Button {
                    isAddingAssociation = true
                } label: {
                    Text(
                        "Add",
                        bundle: .toolkitModule,
                        comment: "A label for a button to add a new utility association."
                    )
                }
                .disabled(options == nil || isAddingAssociation)
            }
        }
        
        /// A section which contains the association type label and the containment visibility toggle.
        var sectionForAssociation: some View {
            Section {
                LabeledContent {
                    switch filter.kind {
                    case .attachment, .structure:
                        UtilityAssociation.Kind.attachment.name
                    case .container, .content:
                        UtilityAssociation.Kind.containment.name
                    default:
                        UtilityAssociation.Kind.connectivity.name
                    }
                } label: {
                    Text.associationType
                }
                if includeContentVisibility {
                    Toggle(isOn: $contentIsVisible) {
                        Text(
                            "Content Visible",
                            bundle: .toolkitModule,
                            comment: """
                            A label indicating whether content in the new
                            association is visible or not.
                            """
                        )
                    }
                }
            }
        }
        
        /// A section which contains a label for the feature on the from side of the association.
        var sectionForFromElement: some View {
            Section {
                LabeledContent {
                    Text(candidateIsToElement ? embeddedFeatureFormViewModel.title : candidate.title)
                } label: {
                    Text.fromElement
                }
                // TODO: (Ref: Apollo 1368) Add terminal configuration settings depending on value of formFeatureTerminalConfiguration and candidateFeatureTerminalConfiguration
            }
        }
        
        /// A section which contains a label for the feature on the to side of the association.
        var sectionForToElement: some View {
            Section {
                LabeledContent {
                    Text(candidateIsToElement ? candidate.title : embeddedFeatureFormViewModel.title)
                } label: {
                    Text.toElement
                }
                // TODO: (Ref: Apollo 1368) Add terminal configuration settings depending on value of formFeatureTerminalConfiguration and candidateFeatureTerminalConfiguration
            }
        }
        
        /// A section which contains the fraction along edge slider.
        @ViewBuilder var sectionForFractionAlongEdge: some View {
            if options?.isFractionAlongEdgeValid ?? false {
                Section {
                    LabeledContent {
                        Text(fractionAlongEdge, format: .percent.precision(.fractionLength(0)))
                    } label: {
                        Text(LocalizedStringResource.fractionAlongEdge)
                    }
                    Slider(value: $fractionAlongEdge, in: 0...1) { _ in
                        LocalizedStringResource.fractionAlongEdge
                    }
                }
            }
        }
    }
    
    /// A error that occurred while adding a utility association.
    private enum AddAssociationError: LocalizedError {
        case anyError(any Error)
        case other(String)
        
        var errorDescription: String? {
            switch self {
            case .anyError(let error):
                error.localizedDescription
            case .other(let message):
                message
            }
        }
    }
}
