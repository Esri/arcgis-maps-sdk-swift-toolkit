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
    
    /// The selected map area.
    @State private var selectedRect: CGRect = .zero
    
    /// The extent of the selected map area.
    @State private var selectedExtent: Envelope?
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating that the map is ready.
    @State private var mapIsReady = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                MapViewReader { mapViewProxy in
                    VStack {
                        VStack(spacing: 0) {
                            Divider()
                            Text("Pan and zoom to define the area")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                            Divider()
                            mapView
                                .overlay {
                                    if mapIsReady {
                                        // Don't add the selector view until the map is ready.
                                        SelectorView(boundingRect: $selectedRect)
                                    }
                                }
                                .onChange(of: selectedRect) { _ in
                                    selectedExtent = mapViewProxy.envelope(fromViewRect: selectedRect)
                                }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        bottomPane(mapView: mapViewProxy)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                }
                .navigationBarTitle("Select Area")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    @ViewBuilder
    private var mapView: some View {
        MapView(map: map)
            .onVisibleAreaChanged { _ in mapIsReady = true }
            .magnifierDisabled(true)
            .attributionBarHidden(true)
            .interactionModes([.pan, .zoom])
            // Prevent view from dragging when panning on map view.
            .highPriorityGesture(DragGesture())
            .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    private func bottomPane(mapView: MapViewProxy) -> some View {
        BottomCard(background: Color(uiColor: .systemBackground)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                    NewTitleButton(title: title, isValidCheck: titleIsValidCheck) {
                        title = $0
                    }
                }
                
                HStack {
                    Picker("Level of detail", selection: $maxScale) {
                        ForEach(CacheScale.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.footnote)
                    .pickerStyle(.navigationLink)
                }
                .padding(.vertical, 6)
                
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
                        Label("Download", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedExtent == nil)
                }
            }
            .padding()
        }
    }
}

/// A View that allows renaming of a map area.
private struct NewTitleButton: View {
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
            Image(systemName: "pencil")
        }
        .alert("Enter a name", isPresented: $alertIsShowing) {
            TextField("Enter area name", text: $proposedNewTitle)
            Button("OK", action: submitNewTitle)
                .disabled(!proposedTitleIsValid)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The name for the map area must be unique.")
        }
        .onChange(of: proposedNewTitle) {
            proposedTitleIsValid = isValidCheck($0)
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
        let scale = UIScreen.main.scale
        
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





struct SelectorView: View {
    @Binding var boundingRect: CGRect
    @State var maxRect: CGRect = .zero
    
    @State private var topLeft: CGPoint = .zero
    @State private var topRight: CGPoint = .zero
    @State private var bottomLeft: CGPoint = .zero
    @State private var bottomRight: CGPoint = .zero
    
    /// The safe area insets we need to add to the contentInsets before passing to core.
    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()
    
    enum DragPoint {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.2))
                    .allowsHitTesting(false)
                    .frame(width: boundingRect.width, height: boundingRect.height)
                    .position(CGPoint(x: boundingRect.midX, y: boundingRect.midY))
                
                Handle(position: topLeft, color: .blue) {
                    resize(for: .topLeft, location: $0)
                }
                
                Handle(position: topRight, color: .green) {
                    resize(for: .topRight, location: $0)
                }
                
                Handle(position: bottomLeft, color: .yellow) {
                    resize(for: .bottomLeft, location: $0)
                }
                
                Handle(position: bottomRight, color: .pink) {
                    resize(for: .bottomRight, location: $0)
                }
            }
            .onChange(of: safeAreaInsets) { _ in
                let frame = CGRect(
                    x: safeAreaInsets.leading,
                    y: safeAreaInsets.top,
                    width: geometry.size.width - safeAreaInsets.trailing - safeAreaInsets.leading,
                    height: geometry.size.height - safeAreaInsets.bottom - safeAreaInsets.top
                )
                
                maxRect = frame
                    .insetBy(
                        dx: 50,
                        dy: 50
                    )
                boundingRect = maxRect
                
                updateHandles()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onGeometryChange(for: EdgeInsets.self, of: \.safeAreaInsets) { safeAreaInsets in
            self.safeAreaInsets = safeAreaInsets
        }
        //.background(Color.black.opacity(0.1).ignoresSafeArea().allowsHitTesting(false))
    }
    
    private func resize(for handle: DragPoint, location: CGPoint) -> Void {
        // Resize the rect.
        let rectangle: CGRect
        
        switch handle {
        case .topLeft:
            let minX = location.x
            let maxX = boundingRect.maxX
            let minY = location.y
            let maxY = boundingRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .topRight:
            let minX = boundingRect.minX
            let maxX = location.x
            let minY = location.y
            let maxY = boundingRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .bottomLeft:
            let minX = location.x
            let maxX = boundingRect.maxX
            let minY = boundingRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        case .bottomRight:
            let minX = boundingRect.minX
            let maxX = location.x
            let minY = boundingRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        }
        
        // First keep rectangle within initial rect.
        var corrected = CGRectIntersection(maxRect, rectangle)
        
        // Now keep rectangle outside minimum rect.
        corrected = CGRectUnion(corrected, minimumRect(forHandle: handle))
        
        boundingRect = corrected
        
        // Now update handles for new bounding rect.
        updateHandles()
    }
    
    private func minimumRect(forHandle handle: DragPoint) -> CGRect {
        let maxWidth: CGFloat = 50
        let maxHeight: CGFloat  = 50
        
        switch handle {
        case .topLeft:
            // Anchor is opposite corner.
            return CGRect(
                x: boundingRect.maxX - maxWidth,
                y: boundingRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .topRight:
            return CGRect(
                x: boundingRect.minX,
                y: boundingRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomLeft:
            return CGRect(
                x: boundingRect.maxX - maxWidth,
                y: boundingRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomRight:
            return CGRect(
                x: boundingRect.minX,
                y: boundingRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        }
    }
    
    private func updateHandles() {
        topRight = CGPoint(x: boundingRect.maxX, y: boundingRect.minY)
        topLeft = CGPoint(x: boundingRect.minX, y: boundingRect.minY)
        bottomLeft = CGPoint(x: boundingRect.minX, y: boundingRect.maxY)
        bottomRight = CGPoint(x: boundingRect.maxX, y: boundingRect.maxY)
    }
    
    struct Handle: View {
        let position: CGPoint
        let color: Color
        let resize: (CGPoint) -> Void
        
        var body: some View {
            color
                .contentShape(Rectangle())
                .frame(width: 44, height: 44)
                .position(position)
                .gesture(DragGesture(coordinateSpace: .local)
                    .onChanged { value in
                        resize(value.location)
                    }
                )
            
        }
    }
}
