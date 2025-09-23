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

struct UtilityAssociationCreationView: View {
    /// The navigation path for the navigation stack presenting this view.
    @Environment(\.navigationPath) var navigationPath
    
    /// <#Description#>
    let candidate: UtilityAssociationFeatureCandidate
    /// The element to add the new association to.
    let element: UtilityAssociationsFormElement
    /// <#Description#>
    let filter: UtilityAssociationsFilter
    
    /// <#Description#>
    @State private var contentIsVisible: Bool = false
    /// <#Description#>
    @State private var fractionAlongEdge: Double = 0.5
    /// <#Description#>
    @State private var options: UtilityAssociationFeatureOptions? = nil
    /// <#Description#>
    @State private var isAddingAssociation = false
    
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
    
    /// <#Description#>
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
    
    /// <#Description#>
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
    
    /// <#Description#>
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
    
    /// <#Description#>
    var sectionForFromElement: some View {
        Section {
            LabeledContent {
                // TODO: Determine what is considered the from element.
            } label: {
                Text.fromElement
            }
        }
    }
    
    /// <#Description#>
    var sectionForToElement: some View {
        Section {
            LabeledContent {
                // TODO: Determine what is considered the to element.
            } label: {
                Text.toElement
            }
        }
    }
    
    /// <#Description#>
    @ViewBuilder var sectionForFractionAlongEdge: some View {
        if options?.isFractionAlongEdgeValid ?? false {
            Section {
                LabeledContent {
                    Text(fractionAlongEdge, format: .percent)
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
