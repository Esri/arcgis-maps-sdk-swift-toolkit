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
        
        /// A Boolean value indicating if the content in a containment association is visible.
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
            .task {
                options = try? await element.options(forAssociationCandidate: candidate.feature)
                print(options, options?.terminalConfiguration, options?.isFractionAlongEdgeValid)
            }
            .task(id: isAddingAssociation) {
                guard isAddingAssociation else { return }
                defer { isAddingAssociation = false }
                await addAssociation()
            }
        }
        
        /// Adds the configured association and modifies the navigation path to return the user to the correct
        /// location.
        func addAssociation() async {
            guard let options else { return }
            do {
                switch (options.isFractionAlongEdgeValid, options.terminalConfiguration) {
                case (false, .none):
                    try await element.addAssociation(feature: candidate.feature, filter: filter)
                case let (false, .some(configuration)):
                    try await element.addAssociation(feature: candidate.feature, filter: filter)
                case (true, .none):
                    try await element.addAssociation(feature: candidate.feature, filter: filter, fractionAlongEdge: fractionAlongEdge)
                case let (true, .some(configuration)):
                    try await element.addAssociation(feature: candidate.feature, filter: filter, fractionAlongEdge: fractionAlongEdge)
                }
                navigationPath?.wrappedValue.removeLast(3)
            } catch {
                // TODO: Log or alert this error.
                print(error.localizedDescription)
            }
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
                    // TODO: Determine association type.
                } label: {
                    Text.associationType
                }
                // TODO: Only show toggle when needed
                if true {
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
                    // TODO: Determine what is considered the from element.
                } label: {
                    Text.fromElement
                }
            }
        }
        
        /// A section which contains a label for the feature on the to side of the association.
        var sectionForToElement: some View {
            Section {
                LabeledContent {
                    // TODO: Determine what is considered the to element.
                } label: {
                    Text.toElement
                }
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
}
