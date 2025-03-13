// Copyright 2022 Esri
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

public extension View {
    /// A floating panel is a view that overlays a view and supplies view-related
    /// content. For more information see <doc:FloatingPanel>.
    ///
    /// - Parameters:
    ///   - attributionBarHeight: The height of a geo-view's attribution bar.
    ///   - backgroundColor: The background color of the floating panel.
    ///   - selectedDetent: A binding to the currently selected detent.
    ///   - horizontalAlignment: The horizontal alignment of the floating panel.
    ///   - isPresented: A binding to a Boolean value that determines whether the view is presented.
    ///   - maxWidth: The maximum width of the floating panel.
    ///   - content: A closure that returns the content of the floating panel.
    /// - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(visionOS, unavailable, message: "Use 'featureEditor(attributionBarHeight:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    func featureEditor<Content>(
        attributionBarHeight: CGFloat = 0,
        backgroundColor: Color = Color(uiColor: .systemBackground),
        selectedDetent: Binding<FloatingPanelDetent>? = nil,
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool> = .constant(true),
        maxWidth: CGFloat = 400,
        featureForm: Binding<FeatureForm?>,
        geometryEditor: GeometryEditor,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FeatureEditorModifier(
                attributionBarHeight: attributionBarHeight,
                backgroundColor: backgroundColor,
                boundDetent: selectedDetent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                featureForm: featureForm,
                geometryEditor: geometryEditor,
                panelContent: content
            )
        )
    }
    
    /// A floating panel is a view that overlays a view and supplies view-related
    /// content. For more information see <doc:FloatingPanel>.
    /// - Parameters:
    ///   - attributionBarHeight: The height of a geo-view's attribution bar.
    ///   - selectedDetent: A binding to the currently selected detent.
    ///   - horizontalAlignment: The horizontal alignment of the floating panel.
    ///   - isPresented: A binding to a Boolean value that determines whether the view is presented.
    ///   - maxWidth: The maximum width of the floating panel.
    ///   - content: A closure that returns the content of the floating panel.
    /// - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    @available(visionOS 2.0, *)
    @available(iOS, unavailable, message: "Use 'featureEditor(attributionBarHeight:backgroundColor:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    @available(macCatalyst, unavailable, message: "Use 'featureEditor(attributionBarHeight:backgroundColor:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    func featureEditor<Content>(
        attributionBarHeight: CGFloat = 0,
        selectedDetent: Binding<FloatingPanelDetent>? = nil,
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool> = .constant(true),
        maxWidth: CGFloat = 400,
        featureForm: Binding<FeatureForm?>,
        geometryEditor: GeometryEditor,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FeatureEditorModifier(
                attributionBarHeight: attributionBarHeight,
                backgroundColor: nil,
                boundDetent: selectedDetent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                featureForm: featureForm,
                geometryEditor: geometryEditor,
                panelContent: content
            )
        )
    }
}

/// Overlays a floating panel on the parent content.
private struct FeatureEditorModifier<PanelContent>: ViewModifier where PanelContent: View {
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// The height of a geo-view's attribution bar.
    ///
    /// When the panel is detached from the bottom of the screen this value allows
    /// the panel to be aligned correctly between the top of a geo-view and the top of the
    /// its attribution bar.
    let attributionBarHeight: CGFloat
    
    /// The background color of the floating panel.
    let backgroundColor: Color?
    
    /// A user provided detent.
    let boundDetent: Binding<FloatingPanelDetent>?
    
    /// A managed detent when a user bound one isn't provided.
    @State private var managedDetent: FloatingPanelDetent = .half
    
    /// The horizontal alignment of the floating panel.
    let horizontalAlignment: HorizontalAlignment
    
    /// A binding to a Boolean value that determines whether the view is presented.
    let isPresented: Binding<Bool>
    
    /// The maximum width of the floating panel.
    let maxWidth: CGFloat
    
    let featureForm: Binding<FeatureForm?>
    
    let geometryEditor: GeometryEditor
    
    /// The content to be displayed within the floating panel.
    let panelContent: () -> PanelContent

    func body(content: Content) -> some View {
        ZStack {
            content
                .overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
                    FloatingPanel(
                        attributionBarHeight: attributionBarHeight,
                        backgroundColor: backgroundColor,
                        selectedDetent: boundDetent ?? $managedDetent,
                        isPresented: isPresented,
                        content: panelContent
                    )
                    .frame(maxWidth: isPortraitOrientation ? .infinity : maxWidth)
                }
            HStack {
                VStack {
                    if featureForm.wrappedValue != nil {
                        FeatureEditorToolbar(featureForm: featureForm, geometryEditor: geometryEditor)
                            .frame(maxWidth: 300)
                            .esriBorder()
                            .padding(24)
                        Spacer()
                    }
                }
                Spacer()
            }
        }
    }
}

struct FeatureEditorToolbar: View {
    //    /// The height of the map view's attribution bar.
    //    @State private var attributionBarHeight: CGFloat = 0
    //
    //    /// The height to present the form at.
    //    @State private var detent: FloatingPanelDetent = .full
    //
    //    /// The presented feature form.
    //    @State private var featureForm: FeatureForm?
    //
    //    /// The point on the screen the user tapped on to identify a feature.
    //    @State private var identifyScreenPoint: CGPoint?
    //
    // #warning("TO BE UNDONE. For UN testing only.")
    //    /// The `Map` displayed in the `MapView`.
    //    @State private var map = makeMap()
    ////    @State private var map = Map(url: .sampleData)!
    
    /// The form view model provides a channel of communication between the form view and its host.
    //    @StateObject private var model = Model()
    
//    var editorType: Binding<FeatureEditorView.EditorType>
    let featureForm: Binding<FeatureForm?>
    
    let geometryEditor: GeometryEditor
    
    @State var hasEdits = false
    @State var geometryChanged: Bool = false
    
//    init(featureForm: Binding<FeatureForm?>) {
//        self.featureForm = featureForm
//    }

    var body: some View {
        VStack(alignment: .center) {
            Text("Feature Editor")
                .font(.title3)
            Divider()
            Group {
                if geometryChanged {
                    Text("The geometry has changed")
                        .foregroundStyle(.red)
                }
                if hasEdits {
                    Text("The attributes have edits")
                        .foregroundStyle(.red)
                }
            }
            .italic()
            HStack {
                Button("Discard", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                    // Start Geometry Editing
                    //                editorType.wrappedValue = .geometry
                }
                .labelStyle(.titleOnly)
                .disabled(!hasEdits && !geometryChanged)
                Spacer()
                //            .buttonStyle(.plain)
                //            .buttonBorderShape(.roundedRectangle)
                //            .font(.largeTitle)
                //            Spacer()
                //            Button("Geometry", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                //                // Start Geometry Editing
                //                editorType.wrappedValue = .geometry
                //            }
                //            .labelStyle(.iconOnly)
                //            .buttonStyle(.borderedProminent)
                //            .buttonBorderShape(.roundedRectangle)
                //            .font(.title)
                //            Button("Attributes", systemImage: "list.bullet.rectangle.portrait") {
                //                // Start Geometry Editing
                //                editorType.wrappedValue = .attributes
                //            }
                //            .labelStyle(.iconOnly)
                //            .buttonStyle(.borderedProminent)
                //            .buttonBorderShape(.roundedRectangle)
                //            .font(.title)
                //            Spacer()
                Button("Save", systemImage: "list.bullet.rectangle.portrait") {
                    // Start Attribute Editing
                    //                editorType.wrappedValue = .attributes
                }
                .disabled(!hasEdits && !geometryChanged)
                .labelStyle(.titleOnly)
                //            .buttonStyle(.plain)
                //            .buttonBorderShape(.roundedRectangle)
                //            .font(.largeTitle)
            }
            .padding()
            .task() {
                for await hasEdits in featureForm.wrappedValue!.$hasEdits {
                    self.hasEdits = hasEdits
                }
            }
            .task(id: ObjectIdentifier(geometryEditor)) {
                for await _ in geometryEditor.$geometry.dropFirst() {
                    self.geometryChanged = true
                }
            }
        }
        
        //            Button("Geometry", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
        //                // Start Geometry Editing
        //                editorType.wrappedValue = .geometry
        //            }
        //            .labelStyle(.iconOnly)
        //            .buttonStyle(.borderedProminent)
        //            .buttonBorderShape(.roundedRectangle)
        //            .font(.largeTitle)
        //
        //            Button("Atrributes", systemImage: "list.bullet.rectangle.portrait") {
        //                // Start Attribute Editing
        //                editorType.wrappedValue = .attributes
        //            }
        //            .labelStyle(.iconOnly)
        //            .buttonStyle(.borderedProminent)
        //            .buttonBorderShape(.roundedRectangle)
        //            .font(.largeTitle)
        //        }
    }
}

//#if !os(visionOS)
//#Preview {
//    FeatureEditorToolbar()
//}
//#endif
