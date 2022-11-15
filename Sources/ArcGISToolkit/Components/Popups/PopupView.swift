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
import UIKit

/// A view displaying the elements of a single Popup.
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
        Group {
            if #available(iOS 16.0, *) {
                PopupViewNavigationStack(
                    popup: self.popup,
                    isPresented: isPresented,
                    showCloseButton: showCloseButton,
                    evaluateExpressionsResult: evaluateExpressionsResult
                )
            } else {
                PopupViewNoNavigation(
                    popup: self.popup,
                    isPresented: isPresented,
                    showCloseButton: showCloseButton,
                    evaluateExpressionsResult: evaluateExpressionsResult
                )
            }
        }
        .task(id: ObjectIdentifier(popup)) {
            evaluateExpressionsResult = nil
            evaluateExpressionsResult = await Result {
                try await popup.evaluateExpressions()
            }
        }
    }
    
    struct PopupViewNoNavigation: View {
        let popup: Popup
        private var evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
        private var showCloseButton = false
        private var isPresented: Binding<Bool>?
        
        /// Creates a `PopupView` with the given popup.
        /// - Parameters
        ///     popup: The popup to display.
        ///   - isPresented: A Boolean value indicating if the view is presented.
        public init(
            popup: Popup,
            isPresented: Binding<Bool>? = nil,
            showCloseButton: Bool,
            evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
        ) {
            self.popup = popup
            self.isPresented = isPresented
            self.showCloseButton = showCloseButton
            self.evaluateExpressionsResult = evaluateExpressionsResult
        }
        
        var body: some View {
            VStack {
                PopupViewTitle(
                    popup: self.popup,
                    isPresented: isPresented,
                    showCloseButton: showCloseButton
                )
                PopupViewBody(
                    popup: self.popup,
                    isPresented: isPresented,
                    showCloseButton: showCloseButton,
                    evaluateExpressionsResult: evaluateExpressionsResult
                )
            }
        }
    }
    
    // TODO: figure out better way to handle v16 vs v15.
    @available(iOS 16.0, *)
    struct PopupViewNavigationStack: View {
        let popup: Popup
        private var evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
        private var showCloseButton = false
        private var isPresented: Binding<Bool>?
        @State private var navigationPath = NavigationPath()
        
        /// Creates a `PopupView` with the given popup.
        /// - Parameters
        ///     popup: The popup to display.
        ///   - isPresented: A Boolean value indicating if the view is presented.
        public init(
            popup: Popup,
            isPresented: Binding<Bool>? = nil,
            showCloseButton: Bool,
            evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
        ) {
            self.popup = popup
            self.isPresented = isPresented
            self.showCloseButton = showCloseButton
            self.evaluateExpressionsResult = evaluateExpressionsResult
        }
        
        var body: some View {
            NavigationStack(path: $navigationPath) {
                VStack {
                    PopupViewTitle16(
                        navigationPath: $navigationPath,
                        popup: self.popup,
                        isPresented: isPresented,
                        showCloseButton: showCloseButton
                    )
                    PopupViewBody(
                        popup: self.popup,
                        isPresented: isPresented,
                        showCloseButton: showCloseButton,
                        evaluateExpressionsResult: evaluateExpressionsResult
                    )
                }
                .navigationDestination(for: Array<Popup>.self) { popupArray in
                    VStack(alignment: .leading) {
                        PopupViewTitle16(
                            navigationPath: $navigationPath,
                            title: "Related Popups",
                            isPresented: isPresented,
                            showCloseButton: showCloseButton
                        )
                        ForEach(popupArray, id:\Popup.self) { popup in
                            NavigationLink(value: popup) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        // TODO: need to display popupElement.relatedPopupDescription here.
                                        Text(popup.title)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding([.bottom], -2)
                            Divider()
                        }
                        Spacer()
                    }
                    .navigationBarHidden(true)
                }
                .navigationDestination(for: Popup.self) { popup in
                    PopupViewInternal16Internal(
                        navigationPath: $navigationPath,
                        popup: popup,
                        isPresented: isPresented,
                        showCloseButton: showCloseButton,
                        evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>.success([])
                    )
                    .navigationBarHidden(true)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct PopupViewInternal16Internal: View {
    let popup: Popup
    private var evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
    private var showCloseButton = false
    private var isPresented: Binding<Bool>?
    private var navigationPath: Binding<NavigationPath>
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        navigationPath: Binding<NavigationPath>,
        popup: Popup,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool,
        evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
    ) {
        self.popup = popup
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
        self.evaluateExpressionsResult = evaluateExpressionsResult
        self.navigationPath = navigationPath
    }
    
    var body: some View {
        VStack {
            PopupViewTitle16(
                navigationPath: navigationPath,
                popup: self.popup,
                isPresented: isPresented,
                showCloseButton: showCloseButton
            )
            PopupViewBody(
                popup: self.popup,
                isPresented: isPresented,
                showCloseButton: showCloseButton,
                evaluateExpressionsResult: evaluateExpressionsResult
            )
        }
    }
}

struct PopupViewTitle: View {
    let title: String
    private var showCloseButton = false
    private var isPresented: Binding<Bool>?
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        popup: Popup,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool
    ) {
        self.title = popup.title
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
    }
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        title: String,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool
    ) {
        self.title = title
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if !title.isEmpty {
                    Text(title)
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
                }
            }
            Divider()
        }
    }
}

@available(iOS 16.0, *)
struct PopupViewTitle16: View {
    private var navigationPath: Binding<NavigationPath>
    private let title: String
    private var showCloseButton = false
    private var isPresented: Binding<Bool>?
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        navigationPath: Binding<NavigationPath>,
        popup: Popup,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool
    ) {
        self.navigationPath = navigationPath
        self.title = popup.title
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
    }
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        navigationPath: Binding<NavigationPath>,
        title: String,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool
    ) {
        self.navigationPath = navigationPath
        self.title = title
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if navigationPath.wrappedValue.count > 0 {
                    Button(action: {
                        navigationPath.wrappedValue.removeLast()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Back")
                    })
                    .padding([.trailing], 12)
                }
                if !title.isEmpty {
                    Text(title)
                        .font(navigationPath.wrappedValue.count > 0 ? .headline : .title)
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
                }
            }
            .padding([.top, .bottom], navigationPath.wrappedValue.count == 0 ? -2 : 0)
            Divider()
        }
    }
}

struct PopupViewBody: View {
    let popup: Popup
    private var evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
    private var showCloseButton = false
    private var isPresented: Binding<Bool>?
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(
        popup: Popup,
        isPresented: Binding<Bool>? = nil,
        showCloseButton: Bool,
        evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>?
    ) {
        self.popup = popup
        self.isPresented = isPresented
        self.showCloseButton = showCloseButton
        self.evaluateExpressionsResult = evaluateExpressionsResult
    }
    
    var body: some View {
        Group {
            if let evaluateExpressionsResult {
                switch evaluateExpressionsResult {
                case .success(_):
                    PopupElementScrollView(popupElements: popup.evaluatedElements, popup: popup)
                case .failure(let error):
                    Text("Popup evaluation failed: \(error.localizedDescription)")
                }
            } else {
                VStack(alignment: .center) {
                    Text("Evaluating popup expressions...")
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct PopupElementScrollView: View {
    let popupElements: [PopupElement]
    let popup: Popup
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(popupElements) { popupElement in
                    switch popupElement {
                    case let popupElement as AttachmentsPopupElement:
                        AttachmentsPopupElementView(popupElement: popupElement)
                    case let popupElement as FieldsPopupElement:
                        FieldsPopupElementView(popupElement: popupElement)
                    case let popupElement as MediaPopupElement:
                        MediaPopupElementView(popupElement: popupElement)
                    case let popupElement as RelationshipPopupElement:
                        if #available(iOS 16.0, *) {
                            RelationshipPopupElementView(
                                popupElement: popupElement,
                                geoElement: popup.geoElement
                            )
                        }
                    case let popupElement as TextPopupElement:
                        TextPopupElementView(popupElement: popupElement)
                    default:
                        EmptyView()
                    }
                }
            }
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
