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

/// The `FeatureFormView` component enables users to edit field values of a feature using
/// pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
///
/// Forms are currently only supported in maps. The form definition is stored
/// in the web map itself and contains a title, description, and a list of "form elements".
///
/// `FeatureFormView` will support the display of form elements created by
/// the Map Viewer or Field Maps Designer, including:
///
/// - Field Element - used to edit a single field of a feature with a specific "input type".
/// - Group Element - used to group field elements together. Group Elements
/// can be expanded, to show all enclosed field elements, or collapsed, hiding
/// the field elements it contains.
///
/// A Field Element has a single input type object. The following are the supported input types:
///
/// - Combo Box - long lists of coded value domains
/// - Date/Time - date/time picker
/// - Radio Buttons - short lists of coded value domains
/// - Switch - two mutually exclusive values
/// - Text Area - multi-line text area
/// - Text Box - single-line text box
///
/// **Features**
///
/// - Display a form editing view for a feature based on the feature form definition defined in a web map.
/// - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
/// - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
/// - Fully supports dark mode, as do all Toolkit components.
///
/// **Behavior**
///
/// The feature form view can be embedded in any type of container view including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/Forms/Examples/Examples)
/// and refer to
/// [FeatureFormExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/Forms/Examples/Examples/FeatureFormExampleView.swift)
/// in the project. To learn more about using the `FeatureFormView` see the [FeatureFormView Tutorial](https://developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/featureformviewtutorial).
/// 
/// - Since: 200.4
public struct FeatureFormView: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The view model for the form.
    @StateObject private var model: FormViewModel
    
    /// A Boolean value indicating whether the initial expression evaluation is running.
    @State private var isEvaluatingInitialExpressions = true
    
    /// The title of the feature form view.
    @State private var title = ""
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        _model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
    }
    
    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                if isEvaluatingInitialExpressions {
                    ProgressView()
                } else {
                    VStack(alignment: .leading) {
                        FormHeader(title: title)
                            .padding(.bottom, elementPadding)
                        ForEach(model.visibleElements, id: \.self) { element in
                            makeElement(element)
                        }
                    }
                }
            }
            .onChange(of: model.focusedElement) { _ in
                if let focusedElement = model.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
            .onTitleChange(of: model.featureForm) { newTitle in
                title = newTitle
            }
        }
        .scrollDismissesKeyboard(
            // Allow tall multiline text fields to be scrolled
            immediately: (model.focusedElement as? FieldFormElement)?.input is TextAreaFormInput ? false : true
        )
        .environmentObject(model)
        .task {
            // Perform the initial expression evaluation.
            await model.initialEvaluation()
            isEvaluatingInitialExpressions = false
        }
    }
}

extension FeatureFormView {
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as GroupFormElement:
            GroupView(element: element, viewCreator: { makeFieldElement($0) })
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
        if !(element.input is UnsupportedFormInput) {
            InputWrapper(element: element)
            Divider()
        }
    }
}
