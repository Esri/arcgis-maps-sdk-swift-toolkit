// Copyright 2023 Esri
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

internal import os

/// The `FeatureFormView` component enables users to edit field values of a feature using
/// pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
///
/// ![An image of the FeatureFormView component](FeatureFormView)
///
/// Forms are currently only supported in maps. The form definition is stored
/// in the web map itself and contains a title, description, and a list of "form elements".
///
/// `FeatureFormView` supports the display of form elements created by
/// the Map Viewer or Field Maps Designer, including:
///
/// - Attachments Element - used to display and edit attachments.
/// - Field Element - used to edit a single field of a feature with a specific "input type".
/// - Group Element - used to group elements together. Group Elements
/// can be expanded, to show all enclosed elements, or collapsed, hiding
/// the elements it contains.
/// - Text Element - used to display read-only plain or Markdown-formatted text.
/// - Utility Associations Element - used to edit associations in utility networks.
///
/// A Field Element has a single input type object. The following are the supported input types:
///
/// - Barcode - machine readable data
/// - Combo Box - long list of values in a coded value domain
/// - Date/Time - date/time picker
/// - Radio Buttons - short list of values in a coded value domain
/// - Switch - two mutually exclusive values
/// - Text Area - multi-line text area
/// - Text Box - single-line text box
///
/// **Features**
///
/// - Display a form editing view for a feature based on the feature form definition defined in a web map and obtained from either an `ArcGISFeature`, `ArcGISFeatureTable`, `FeatureLayer` or `SubtypeSublayer`.
/// - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
/// - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
/// - Add, delete, or rename feature attachments.
/// - Fully supports dark mode, as do all Toolkit components.
///
/// **Behavior**
///
/// As of 200.8, FeatureFormView uses a NavigationStack internally to support browsing utility network
/// associations. As a result, a FeatureFormView requires a navigation context isolated from any app-level
/// navigation. Basic apps without navigation can continue to place a FeatureFormView where desired.
/// More complex apps using NavigationStack or NavigationSplitView will need to relocate the FeatureFormView
/// outside of that navigation context. If the FeatureFormView can be presented modally (no background
/// interaction with the map is needed), consider using a Sheet. If a non-modal presentation is needed,
/// consider placing the FeatureFormView in a Floating Panel or Inspector, on the app-level navigation container.
/// On supported platforms, WindowGroups are another alternative to consider as a FeatureFormView container.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [FeatureFormExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FeatureFormExampleView.swift)
/// in the project. To learn more about using the `FeatureFormView` see the <doc:FeatureFormViewTutorial>.
///
/// - Note: In order to capture video and photos as form attachments, your application will need
/// `NSCameraUsageDescription` and, `NSMicrophoneUsageDescription` entries in the
/// `Info.plist` file.
///
/// - Since: 200.4
public struct FeatureFormView: View {
    /// The point at which to run feature identification when adding utility associations.
    private let mapPoint: Point?
    
    /// A binding to a Boolean value that determines whether the view is presented.
    private let isPresented: Binding<Bool>?
    
    /// The root feature form.
    private let rootFeatureForm: FeatureForm?
    
    /// The visibility of the "save" and "discard" buttons.
    var editingButtonsVisibility: Visibility = .automatic
    
    /// The user-provided closure to perform when a new feature form is shown in the navigation stack.
    var onFeatureFormChanged: ((FeatureForm) -> Void)?
    
    /// A Boolean which declares whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    var navigationIsDisabled = false
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    var onFormEditingEventAction: ((EditingEvent) -> Void)?
    
    /// The developer configurable validation error visibility.
    var validationErrorVisibilityExternal = ValidationErrorVisibility.automatic
    
    /// Continuation information for the alert.
    @State private var alertContinuation: (willNavigate: Bool, action: () -> Void)?
    
    /// The view model for the feature form view.
    @State private var featureFormViewModel: FeatureFormViewModel
    
    /// An error thrown from finish editing.
    @State private var finishEditingError: (any Error)?
    
    /// The navigation path used by the navigation stack in the root feature form view.
    @State private var navigationPath = NavigationPath()
    
    /// The feature form currently visible in the navigation stack.
    @State private var presentedForm: FeatureForm
    
    /// The internally managed validation error visibility.
    @State private var validationErrorVisibilityInternal = ValidationErrorVisibility.automatic
    
    /// Creates a feature form view.
    /// - Parameters:
    ///   - root: The feature form defining the editing experience.
    ///   - mapPoint: The point at which to run feature identification when adding utility associations.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    /// - Since: 200.8
    public init(
        root: FeatureForm,
        mapPoint: Point? = nil,
        mapViewProxy: MapViewProxy? = nil,
        _ utilityNetwork: UtilityNetwork? = nil /* Temporary parameter only */
    ) {
        self.featureFormViewModel = FeatureFormViewModel(
            mapViewProxy: mapViewProxy,
            utilityNetwork: utilityNetwork
        )
        self.isPresented = .constant(true)
        self.mapPoint = mapPoint
        self.presentedForm = root
        self.rootFeatureForm = root
    }
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - root: The feature form defining the editing experience.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    /// - Since: 200.8
    public init(root: FeatureForm, isPresented: Binding<Bool>? = nil) {
        self.featureFormViewModel = FeatureFormViewModel()
        self.isPresented = isPresented
        self.mapPoint = nil
        self.presentedForm = root
        self.rootFeatureForm = root
    }
    
    public var body: some View {
        if let rootFeatureForm {
            NavigationStack(path: $navigationPath) {
                EmbeddedFeatureFormView(featureForm: rootFeatureForm)
                    // Refresh the navigation stack's root view when the root
                    // feature form changes.
                    .id(ObjectIdentifier(rootFeatureForm))
                    .navigationDestination(for: NavigationPathItem.self) { itemType in
                        switch itemType {
                        case let .form(form):
                            EmbeddedFeatureFormView(featureForm: form)
                        case let .utilityAssociationDetailsView(embeddedFeatureFormViewModel, associationsFilterResultsModel, element, associationResult):
                            UtilityAssociationDetailsView(
                                associationResult: associationResult,
                                associationsFilterResultsModel: associationsFilterResultsModel,
                                element: element,
                                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
                            )
                            .featureFormToolbar(embeddedFeatureFormViewModel.featureForm)
                            .navigationBarTitleDisplayMode(.inline)
                        case let .utilityAssociationFilterResultView(embeddedFeatureFormViewModel, associationsFilterResultsModel, element, filterKind):
                            UtilityAssociationsFilterResultView(
                                associationsFilterResultsModel: associationsFilterResultsModel,
                                element: element,
                                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel,
                                kind: filterKind
                            )
                            .featureFormToolbar(embeddedFeatureFormViewModel.featureForm)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(String.init(localized: filterKind.label), subtitle: embeddedFeatureFormViewModel.title)
                            .preference(
                                key: PresentedFeatureFormPreferenceKey.self,
                                value: .init(object: embeddedFeatureFormViewModel.featureForm)
                            )
                        case let .utilityAssociationGroupResultView(embeddedFeatureFormViewModel, associationsFilterResultsModel, element, filterKind, groupTitle):
                            UtilityAssociationGroupResultView(
                                associationsFilterResultsModel: associationsFilterResultsModel,
                                element: element,
                                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel,
                                filterKind: filterKind,
                                groupTitle: groupTitle
                            )
                            .featureFormToolbar(embeddedFeatureFormViewModel.featureForm)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(groupTitle, subtitle: embeddedFeatureFormViewModel.title)
                        }
                    }
            }
            // Alert for abandoning unsaved edits
            .alert(
                presentedForm.validationErrors.isEmpty ? discardEditsQuestion : validationErrors,
                isPresented: alertForUnsavedEditsIsPresented,
                actions: {
                    if let (willNavigate, continuation) = alertContinuation {
                        Button(role: .destructive) {
                            presentedForm.discardEdits()
                            onFormEditingEventAction?(.discardedEdits(willNavigate: willNavigate))
                            validationErrorVisibilityInternal = .automatic
                            continuation()
                        } label: {
                            discardEdits
                        }
                        .onAppear {
                            if !presentedForm.validationErrors.isEmpty {
                                validationErrorVisibilityInternal = .visible
                            }
                        }
                        if (presentedForm.validationErrors.isEmpty) {
                            Button {
                                Task {
                                    do {
                                        try await presentedForm.finishEditing()
                                        onFormEditingEventAction?(.savedEdits(willNavigate: willNavigate))
                                        continuation()
                                    } catch {
                                        finishEditingError = error
                                    }
                                }
                            } label: {
                                saveEdits
                            }
                        }
                        Button(role: .cancel) {
                            alertForUnsavedEditsIsPresented.wrappedValue = false
                        } label: {
                            continueEditing
                        }
                    }
                },
                message: {
                    if !presentedForm.validationErrors.isEmpty {
                        Text(
                            "You have ^[\(presentedForm.validationErrors.count) error](inflect: true) that must be fixed before saving.",
                            bundle: .toolkitModule,
                            comment:
                                """
                                A message explaining that the indicated number
                                of validation errors must be resolved before
                                saving the feature form.
                                """
                        )
                    } else {
                        Text(
                            "Updates to the form will be lost.",
                            bundle: .toolkitModule,
                            comment:
                                """
                                A message explaining that unsaved edits will be
                                lost if the user continues to dismiss the form
                                without saving.
                                """
                        )
                    }
                }
            )
            // Alert for finish editing errors
            .alert(
                Text(
                    "The form wasn't submitted",
                    bundle: .toolkitModule,
                    comment: "The title shown when the feature form failed to save."
                ),
                isPresented: alertForFinishEditingErrorsIsPresented,
                actions: { },
                message: {
                    if let finishEditingError {
                        Text(
                            """
                            Finish editing failed.
                            \(String(describing: finishEditingError))
                            """,
                            bundle: .toolkitModule,
                            comment:
                                """
                                The message shown when a form could not be 
                                submitted with additional details.
                                """
                        )
                    } else {
                        Text(
                            "Finish editing failed.",
                            bundle: .toolkitModule,
                            comment: "The message shown when a form could not be submitted."
                        )
                    }
                }
            )
            .animation(.default, value: ObjectIdentifier(rootFeatureForm))
            .environment(\.editingButtonVisibility, editingButtonsVisibility)
            .environment(featureFormViewModel)
            .environment(\.finishEditingError, $finishEditingError)
            .environment(\.isPresented, isPresented)
            .environment(\.navigationIsDisabled, navigationIsDisabled)
            .environment(\.navigationPath, $navigationPath)
            .environment(\.onFormEditingEventAction, onFormEditingEventAction)
            .environment(\.setAlertContinuation, setAlertContinuation)
            .environment(\.validationErrorVisibilityExternal, validationErrorVisibilityExternal)
            .environment(\.validationErrorVisibilityInternal, $validationErrorVisibilityInternal)
            .onChange(of: mapPoint) { _, newValue in
                featureFormViewModel.mapPoint = newValue
            }
            .onChange(of: ObjectIdentifier(rootFeatureForm)) {
                presentedForm = rootFeatureForm
            }
            .onPreferenceChange(PresentedFeatureFormPreferenceKey.self) { wrappedFeatureForm in
                guard let wrappedFeatureForm else { return }
                formChangedAction(wrappedFeatureForm.object)
            }
            .overlay {
                if featureFormViewModel.addUtilityAssociationScreenIsPresented {
                    AddUtilityAssociationView()
                }
            }
        }
    }
}

public extension FeatureFormView {
    /// Represents events that occur during the form editing lifecycle.
    /// These events notify you when the user has either saved or discarded their edits.
    /// - Since: 200.8
    enum EditingEvent {
        /// Indicates that the user has discarded their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will navigate after discarding.
        case discardedEdits(willNavigate: Bool)
        /// Indicates that the user has saved their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will navigate after saving.
        case savedEdits(willNavigate: Bool)
    }
    
    /// Sets the visibility of the save and discard buttons on the form.
    /// - Parameter visibility: The visibility of the save and discard buttons.
    /// - Since: 200.8
    func editingButtons(_ visibility: Visibility) -> Self {
        var copy = self
        copy.editingButtonsVisibility = visibility
        return copy
    }
    
    /// Sets whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    ///
    /// Use this modifier to conditionally disable navigation into other forms.
    /// - Parameter disabled: A Boolean value that determines whether navigation is disabled. Pass `true` to disable navigation; otherwise, pass `false`.
    /// - Since: 200.8
    func navigationDisabled(_ disabled: Bool) -> Self {
        var copy = self
        copy.navigationIsDisabled = disabled
        return copy
    }
    
    /// Sets a closure to perform when a new feature form is shown in the view.
    ///
    /// This can happen when navigating through the associations in a `UtilityAssociationsFormElement`.
    /// - Parameter action: The closure to perform when the new feature form is shown.
    /// - Since: 200.8
    func onFeatureFormChanged(perform action: @escaping (FeatureForm) -> Void) -> Self {
        var copy = self
        copy.onFeatureFormChanged = action
        return copy
    }
    
    /// Sets a closure to perform when a form editing event occurs.
    /// - Parameter action: The closure to perform when the form editing event occurs.
    /// - Since: 200.8
    func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> Self {
        var copy = self
        copy.onFormEditingEventAction = action
        return copy
    }
}

extension FeatureFormView {
    /// A Boolean value indicating whether the finish editing error alert is presented.
    var alertForFinishEditingErrorsIsPresented: Binding<Bool> {
        Binding {
            finishEditingError != nil
        } set: { newIsPresented in
            if !newIsPresented {
                finishEditingError = nil
            }
        }
    }
    
    /// A Boolean value indicating whether the unsaved edits alert is presented.
    var alertForUnsavedEditsIsPresented: Binding<Bool> {
        Binding {
            alertContinuation != nil
        } set: { newIsPresented in
            if !newIsPresented {
                alertContinuation = nil
            }
        }
    }
    
    /// The closure to perform when the presented feature form changes.
    ///
    /// - Note: This action has the potential to be called under four scenarios. Whenever an
    /// ``EmbeddedFeatureFormView`` appears (which can happen during forward
    /// or reverse navigation) and whenever a ``UtilityAssociationGroupResultView`` appears
    /// (which can also happen during forward or reverse navigation). Because those two views (and the
    /// intermediate ``UtilityAssociationsFilterResultView`` are all considered to be apart of
    /// the same ``FeatureForm`` make sure not to over-emit form handling events.
    var formChangedAction: (FeatureForm) -> Void {
        { featureForm in
            if featureForm.feature.globalID != presentedForm.feature.globalID {
                featureForm.feature.refresh()
                presentedForm = featureForm
                validationErrorVisibilityInternal = .automatic
                onFeatureFormChanged?(featureForm)
            }
        }
    }
    
    /// A closure used to set the alert continuation.
    var setAlertContinuation: (Bool, @escaping () -> Void) -> Void {
        { willNavigate, continuation in
            alertContinuation = (willNavigate: willNavigate, action: continuation)
        }
    }
    
    // MARK: Localized text
    
    var continueEditing: Text {
        .init(
            "Continue Editing",
            bundle: .toolkitModule,
            comment: "A label for a button to continue editing the feature form."
        )
    }
    
    var discardEdits: Text {
        .init(
            "Discard Edits",
            bundle: .toolkitModule,
            comment: "A label for a button to discard unsaved edits."
        )
    }
    
    var discardEditsQuestion: Text {
        .init(
            "Discard Edits?",
            bundle: .toolkitModule,
            comment: "A question asking if the user would like to discard their unsaved edits."
        )
    }
    
    var saveEdits: Text {
        .init(
            "Save Edits",
            bundle: .toolkitModule,
            comment: "A label for a button to save edits."
        )
    }
    
    var validationErrors: Text {
        .init(
            "Validation Errors",
            bundle: .toolkitModule,
            comment: "A label indicating the feature form has validation errors."
        )
    }
}

extension Logger {
    /// A logger for the feature form view.
    static var featureFormView: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureFormView")
    }
}
