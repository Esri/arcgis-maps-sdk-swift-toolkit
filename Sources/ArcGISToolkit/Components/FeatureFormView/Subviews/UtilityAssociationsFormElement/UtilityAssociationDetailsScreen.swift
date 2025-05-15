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

import SwiftUI

extension FeatureFormView {
    struct UtilityAssociationDetailsScreen: View {
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        var body: some View {
            NavigationLayer { _ in
                UtilityAssociationDetailsCore()
            } headerTrailing: {
                XButton(.dismiss) {
                    withAnimation {
                        featureFormViewModel.utilityAssociationDetailsScreenIsPresented = false
                    }
                }
                .font(.title)
            }
            // TODO: Combine with similar code in FeatureFormView.AddUtilityAssociationScreen.swift
#if os(visionOS)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
#else
            .background(Color(uiColor: .systemGroupedBackground))
#endif
            .transition(.move(edge: .bottom))
        }
    }
    
    struct UtilityAssociationDetailsCore: View {
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        var body: some View {
            List {
                Section {
                    Text("From Element")
                    Text("To Element")
                }
                Section {
                    Text("Association Type")
                    Text("Content Visible")
                }
                
                if let existingAssociation = featureFormViewModel.selectedAssociation {
                    Section {
#warning("Localization needed")
                        Button("Remove Association", role: .destructive) {
                            Task {
                                do {
#warning("API NOT YET IMPLEMENTED")
//                                    try await featureFormViewModel.utilityNetwork?.delete(existingAssociation)
                                    withAnimation {
                                        featureFormViewModel.utilityAssociationDetailsScreenIsPresented = false
                                    }
                                } catch {
#warning("Present failure to user.")
                                    print(String(reflecting: error))
                                }
                            }
                        }
                        .disabled(featureFormViewModel.selectedAssociation == nil || !(featureFormViewModel.utilityNetwork?.canDeleteAssociations ?? false))
                    } footer: {
                        Text("Only removes the association. The feature remains.")
                    }
                } else {
                    Section {
#warning("Localization needed")
                        Button("Add Association") {
                            withAnimation {
                                featureFormViewModel.addUtilityAssociationScreenIsPresented = false
                            }
                        }
                    }
                }
            }
            .navigationLayerTitle("Association Settings")
        }
    }
}
