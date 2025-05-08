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
    struct AddUtilityAssociationScreen: View {
        /// The view model for the feature form view.
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        /// The filter phrase for the network source name.
        @State private var networkSourceNameQuery = ""
        
        var body: some View {
            NavigationLayer { _ in
                List {
                    Section {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                VStack(alignment: .leading) {
                                    Text.selectFeatureOnMap
                                    Text.tapSelectAreaOrDrawPolygon
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .tint(.primary)
                            }
                        }
                    } header: {
                        Text.selectFeatureOnMap
                            .textCase(.none)
                    }
                    
                    Section {
                        TextField(text: $networkSourceNameQuery) {
                            Text.searchNetworkSource
                        }
                    } header: {
                        Text.selectFeatureFromTheNetworkSourceGroup
                            .textCase(.none)
                    }
                    
                    Section {
                        ForEach(filteredSources, id: \.name) { layer in
                            Button {
                                
                            } label: {
                                HStack {
                                    Text(layer.name)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .contentShape(.rect)
                                .tint(.primary)
                            }
                        }
                    }
                }
                .navigationLayerTitle("Add Associations")
            } headerTrailing: {
                XButton(.dismiss) {
                    withAnimation {
                        featureFormViewModel.addUtilityAssociationScreenIsPresented = false
                    }
                }
                .font(.title)
            }
            // TODO: Combine with similar code in FeatureFormView.UtilityAssociationDetailsScreen.swift
            #if os(visionOS)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            #else
            .background(Color(uiColor: .systemGroupedBackground))
            #endif
            .transition(.move(edge: .bottom))
        }
    }
}

private extension FeatureFormView.AddUtilityAssociationScreen {
    /// The set of network sources matching the query, sorted in alphabetical order.
    var filteredSources: [Layer] {
        let allLayers = (featureFormViewModel.utilityNetwork?.layers ?? [])
            .sorted { $0.name < $1.name }
        if networkSourceNameQuery.isEmpty {
            return allLayers
        } else {
            return allLayers
                .filter { $0.name.localizedStandardContains(networkSourceNameQuery) }
        }
    }
}

private extension Text {
    static var searchNetworkSource: Self {
        .init(
            "\(Image(systemName: "magnifyingglass")) Search Network Source",
            bundle: .toolkitModule,
            comment: "A label for a utility network source search field."
        )
    }
    
    static var selectFeatureFromTheNetworkSourceGroup: Self {
        .init(
            "Select feature from the Network Source group",
            bundle: .toolkitModule,
            comment: "A header label for a list of utility network sources."
        )
    }
    
    static var selectFeatureOnMap: Self {
        .init(
            "Select feature on map",
            bundle: .toolkitModule,
            comment: """
                     A label indicating features can be selected by 
                     interactively tapping on the map.
                     """
        )
    }
    
    static var tapSelectAreaOrDrawPolygon: Self {
        .init(
            "Tap, select area, or draw polygon",
            bundle: .toolkitModule,
            comment: ""
        )
    }
}
