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

/// A view that can provides a configuration for taking an on-demand area offline.
struct OnDemandConfigurationView: View {
    /// The online map.
    @State private(set) var map: Map
    
    /// The title of the map area.
    @State private(set) var title: String
    
    /// A check to perform to validate a proposed title for uniqueness.
    let titleIsValidCheck: (String) -> Bool
    
    /// The action to call when creating a configuration is complete.
    let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
    
    /// The max scale of the map to take offline.
    @State private var maxScale: CacheScale = .street
    
    /// The visible area of the map.
    @State private var visibleArea: Envelope?
    
    /// The selected map area.
    @State private var selectedRect: CGRect = .zero
    
    /// The extent of the selected map area.
    @State private var selectedExtent: Envelope?
    
    /// A Boolean value indicating that the map is ready.
    @State private var mapIsReady = false
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating if the download button is disabled.
    private var downloadIsDisabled: Bool { selectedExtent == nil || hasNoInternetConnection }
    
    /// The result of trying to load the map.
    @State private var loadResult: Result<Void, Error>?
    
    /// A Boolean value indicating if there is no internet connection
    private var hasNoInternetConnection: Bool {
        return switch loadResult {
        case .success:
            false
        case .failure(let failure):
            failure.isNoInternetConnectionError
        case nil:
            false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch loadResult {
                case .success:
                    loadedView
                case .failure:
                    failedToLoadView
                case nil:
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button.cancel {
                        dismiss()
                    }
                }
            }
            .task { await loadMap() }
            .navigationBarTitle(
                Text(
                    "Select Area",
                    bundle: .toolkitModule,
                    comment: "A title for the on demand configuration view."
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// Loads the map and sets the result.
    private func loadMap() async {
        switch loadResult {
        case .success:
            return
        case .failure:
            // First set to `nil` so progress indicator can show during load.
            loadResult = nil
            fallthrough
        case nil:
            loadResult = nil
            loadResult = await Result { try await map.retryLoad() }
        }
    }
    
    @ViewBuilder private var loadedView: some View {
        MapViewReader { mapViewProxy in
            VStack(spacing: 0) {
                instructionsView
                MapView(map: map)
                #if !os(visionOS)
                    .magnifierDisabled(true)
                #endif
                    .attributionBarHidden(true)
                    .interactionModes([.pan, .zoom])
                    .onDrawStatusChanged { drawStatus in
                        guard !mapIsReady else { return }
                        if drawStatus == .completed && map.loadStatus == .loaded {
                            mapIsReady = true
                        }
                    }
                    .onVisibleAreaChanged { _ in
                        // Update selected extent when visible area changes.
                        selectedExtent = mapViewProxy.envelope(fromViewRect: selectedRect)
                    }
                    .highPriorityGesture(DragGesture())
                    .highPriorityGesture(RotateGesture())
                    .interactiveDismissDisabled()
                    .overlay {
                        if mapIsReady {
                            // Don't add the selector view until the map is ready.
                            OnDemandMapAreaSelectorView(selectedRect: $selectedRect)
                        }
                    }
                    .onChange(of: selectedRect) {
                        // Update selected extent when selector changes.
                        selectedExtent = mapViewProxy.envelope(fromViewRect: selectedRect)
                    }
            }
            .safeAreaInset(edge: .bottom) {
                bottomPane(mapView: mapViewProxy)
            }
            .ignoresSafeArea(.keyboard, edges: .all)
        }
    }
    
    @ViewBuilder private var instructionsView: some View {
        VStack(spacing: 0) {
            Divider()
            Text(
                "Pan and zoom to define the area",
                bundle: .toolkitModule,
                comment: "A label instructing to pan and zoom the map to define an area."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(8)
            .frame(maxWidth: .infinity)
            Divider()
        }
    }
    
    @ViewBuilder
    private func bottomPane(mapView: MapViewProxy) -> some View {
#if os(visionOS)
        let background = Material.regularMaterial
#else
        let background = Color(uiColor: .systemBackground)
#endif
        BottomCard(background: background) {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                    RenameButton(title: title, isValidCheck: titleIsValidCheck) {
                        title = $0
                    }
                    .disabled(downloadIsDisabled)
                }
                
                Divider()
                
                HStack {
                    Text(
                        "Level of Detail",
                        bundle: .toolkitModule,
                        comment: "A label for the level of detail picker view."
                    )
                    Spacer()
                    Picker(selection: $maxScale) {
                        ForEach(CacheScale.allCases, id: \.self) {
                            Text($0.description)
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        EmptyView()
                    }
                    .disabled(downloadIsDisabled)
                }
                
                HStack {
                    Button {
                        guard let selectedExtent else { return }
                        Task {
                            let image = try? await mapView.exportImage()
                            let thumbnail = image?.crop(to: selectedRect)
                            
                            let configuration = OnDemandMapAreaConfiguration(
                                title: title,
                                minScale: 0,
                                maxScale: maxScale.scale,
                                areaOfInterest: selectedExtent,
                                thumbnail: thumbnail
                            )
                            onCompleteAction(configuration)
                            dismiss()
                        }
                    } label: {
                        Text(
                            "Download",
                            bundle: .toolkitModule,
                            comment: "A label for a button to download a map area."
                        )
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .disabled(downloadIsDisabled)
                    .padding(.top)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder private var failedToLoadView: some View {
        VStack {
            if hasNoInternetConnection {
                Backported.ContentUnavailableView(
                    .noInternetConnectionErrorMessage,
                    systemImage: "wifi.exclamationmark",
                    description: cannotDownloadMessage
                )
            } else {
                Backported.ContentUnavailableView(
                    failedToLoadMessage,
                    systemImage: "exclamationmark.triangle",
                    description: cannotDownloadMessage
                )
            }
            Button {
                Task { await loadMap() }
            } label: {
                Text.tryAgain
                    .buttonStyle(.borderless)
            }
            .padding()
        }
        .padding()
    }
}

/// A View that allows renaming of a map area.
private struct RenameButton: View {
    /// The current title.
    let title: String
    
    /// An validity check for a proposed title.
    let isValidCheck: (String) -> Bool
    
    /// The completion of the rename.
    let completion: (String) -> Void
    
    /// A Boolean value indicating if we are showing the alert to
    /// rename the title.
    @State private var alertIsShowing = false
    
    /// Temporary storage for a proposed title for use when the user is renaming an area.
    @State private var proposedNewTitle: String = ""
    
    /// A Boolean value indicating if the proposed title is valid.
    @State private var proposedTitleIsValid = false
    
    var body: some View {
        Button {
            // Rename the area.
            proposedNewTitle = title
            alertIsShowing = true
        } label: {
            Text.rename
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .font(.subheadline)
        .fontWeight(.semibold)
        .alert(enterName, isPresented: $alertIsShowing) {
            TextField(text: $proposedNewTitle, prompt: areaName) {}
            Button(String.ok, action: submitNewTitle)
                .disabled(!proposedTitleIsValid)
                .keyboardShortcut(.defaultAction)
            Button.cancel {}
        } message: {
            Text(
                "The name for the map area must be unique.",
                bundle: .toolkitModule,
                comment: "A message explaining that the map area name must be unique."
            )
        }
        .onChange(of: proposedNewTitle) {
            proposedTitleIsValid = isValidCheck(proposedNewTitle)
        }
    }
    
    /// Completes the rename.
    private func submitNewTitle() {
        completion(proposedNewTitle)
    }
}

/// A view that displays a card with rounded top edges that will be
/// anchored to the bottom.
private struct BottomCard<Content: View, Background: ShapeStyle>: View {
    /// The content to display in the card.
    let content: () -> Content
    /// The background of the card.
    let background: Background
    
    /// Creates a bottom card.
    init(background: Background, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.background = background
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
                .background(background)
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
            
            // So it extends into the bottom safe area.
            VStack {}
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .background(background)
        }
        .ignoresSafeArea(.container, edges: .horizontal)
    }
}

private extension UIImage {
    /// Crops a UIImage to a certain CGRect of the screen's coordinates.
    /// - Parameter rect: A CGRect in screen coordinates.
    /// - Returns: The cropped image.
    @MainActor
    func crop(to rect: CGRect) -> UIImage? {
        #if os(visionOS)
        let scale: CGFloat = 1
        #else
        let scale = UIScreen.main.scale
        #endif
        
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )
        
        guard let cgImage, let croppedImage = cgImage.cropping(to: scaledRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
    }
}

private extension OnDemandConfigurationView {
    var failedToLoadMessage: LocalizedStringResource {
        .init(
            "Online Map Failed to Load",
            bundle: .toolkit,
            comment: "A message explaining that the online map failed to load."
        )
    }
    
    var cannotDownloadMessage: LocalizedStringResource {
        .init(
            "A map area cannot be downloaded at this time.",
            bundle: .toolkit,
            comment: "A message explaining that a map area cannot be downloaded at this time."
        )
    }
}

private extension RenameButton {
    var enterName: Text {
        .init(
            "Enter a name",
            bundle: .toolkitModule,
            comment: "An instruction to enter a name."
        )
    }
    
    var areaName: Text {
        .init(
            "Area Name",
            bundle: .toolkitModule,
            comment: "A hint for the user to enter an area name in the text field."
        )
    }
}
