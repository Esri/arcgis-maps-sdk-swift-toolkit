// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// The `PopupView` component will display a popup for an individual feature. This includes showing
/// the feature's title, attributes, custom description, media, and attachments. The new online Map
/// Viewer allows users to create a popup definition by assembling a list of “popup elements”.
/// `PopupView` will support the display of popup elements created by the Map Viewer, including:
/// Text, Fields, Attachments, and Media (Images and Charts).
///
/// Thanks to the backwards compatibility support in the API, it will also work with the legacy
/// popup definitions created by the classic Map Viewer. It does not support editing.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://user-images.githubusercontent.com/3998072/203422507-66b6c6dc-a6c3-4040-b996-9c0da8d4e580.png) | ![image](https://user-images.githubusercontent.com/3998072/203422665-c4759c1f-5863-4251-94df-ed7a06ac7a8f.png) |
///
/// > Note: Displaying charts in a popup requires running on a device with iOS 16.0 or greater.
/// Displaying charts on Mac requires building your application with Xcode 14.1 or greater
/// and running on a Mac with macOS 13.0 (Ventura) or greater.  Also, attachment previews are not
/// available when running on Mac (regardless of Xcode version).
///
/// **Features**
///
/// - Display a popup for a feature based on the popup definition defined in a web map.
/// - Supports image refresh intervals on image popup media, refreshing the image at a given
/// interval defined in the popup element.
/// - Supports elements containing Arcade expression and automatically evaluates expressions.
/// - Displays media (images and charts) full-screen.
/// - Supports hyperlinks in text, media, and fields elements.
/// - Fully supports dark mode, as do all Toolkit components.
///
/// **Behavior**
///
/// The popup view can display an optional "close" button, allowing the user to dismiss the view.
/// The popup view can be embedded in any type of container view including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to
/// [PopupExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/PopupExampleView.swift)
/// in the project. To learn more about using the `PopupView` see the [PopupView Tutorial](https://developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/popupviewtutorial).
public struct PopupView: View {
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(popup: Popup, isPresented: Binding<Bool>? = nil) {
        self.popup = popup
        self.isPresented = isPresented
    }
    
    /// The `Popup` to display.
    private let popup: Popup
    
    /// A Boolean value specifying whether a "close" button should be shown or not. If the "close"
    /// button is shown, you should pass in the `isPresented` argument to the initializer,
    /// so that the the "close" button can close the view.
    private var showCloseButton = false
    
    /// The result of evaluating the popup expressions.
    @State private var evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?

    /// A binding to a Boolean value that determines whether the view is presented.
    private var isPresented: Binding<Bool>?
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if !popup.title.isEmpty {
                    Text(popup.title)
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                if showCloseButton {
                    Button(action: {
                        isPresented?.wrappedValue = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                            .padding([.top, .bottom, .trailing], 4)
                    })
                    .buttonStyle(.plain)
                }
            }
            Divider()
            Group {
                if let evaluateExpressionsResult {
                    switch evaluateExpressionsResult {
                    case .success(_):
                        PopupElementList(popupElements: popup.evaluatedElements)
                    case .failure(let error):
                        Text(
                            "Popup evaluation failed: \(error.localizedDescription)",
                            bundle: .toolkitModule,
                            comment: """
                                     An error message shown when a popup cannot be displayed. The
                                     variable provides additional data.
                                     """
                        )
                    }
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        Text(
                            "Evaluating popup expressions",
                            bundle: .toolkitModule,
                            comment: "A label indicating popup expressions are being evaluated."
                        )
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .task(id: ObjectIdentifier(popup)) {
            evaluateExpressionsResult = nil
            evaluateExpressionsResult = await Result {
                try await popup.evaluateExpressions()
            }
        }
    }
    
    private struct PopupElementList: View {
        let popupElements: [PopupElement]
        
        var body: some View {
            List(popupElements) { popupElement in
                Group {
                    switch popupElement {
                    case let popupElement as AttachmentsPopupElement:
                        AttachmentsPopupElementView(popupElement: popupElement)
                    case let popupElement as FieldsPopupElement:
                        FieldsPopupElementView(popupElement: popupElement)
                    case let popupElement as MediaPopupElement:
                        MediaPopupElementView(popupElement: popupElement)
                    case let popupElement as TextPopupElement:
                        TextPopupElementView(popupElement: popupElement)
                    default:
                        EmptyView()
                    }
                }
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .listStyle(.plain)
        }
    }
}

extension PopupView {
    /// Specifies whether a "close" button should be shown to the right of the popup title. If the "close"
    /// button is shown, you should pass in the `isPresented` argument to the `PopupView`
    /// initializer, so that the the "close" button can close the view.
    /// Defaults to `false`.
    /// - Parameter newShowCloseButton: The new value.
    /// - Returns: A new `PopupView`.
    public func showCloseButton(_ newShowCloseButton: Bool) -> Self {
        var copy = self
        copy.showCloseButton = newShowCloseButton
        return copy
    }
}
