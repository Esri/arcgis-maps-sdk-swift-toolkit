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
                List {
                    Section {
                        Text("From Element")
                        Text("To Element")
                    }
                    Section {
                        Text("Association Type")
                        Text("Content Visible")
                    }
                    Section {
                        Button("Remove Association", role: .destructive) {
                            
                        }
                    } footer: {
                        Text("Only removes the association. The feature remains.")
                    }
                }
                .navigationLayerTitle("Association Settings")
            } headerTrailing: {
                XButton(.dismiss) {
                    withAnimation {
                        featureFormViewModel.utilityAssociationDetailsScreenIsPresented = false
                    }
                }
                .font(.title)
            }
            #if os(visionOS)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            #else
            .background(Color(uiColor: .systemGroupedBackground))
            #endif
            .transition(.move(edge: .bottom))
        }
    }
}
