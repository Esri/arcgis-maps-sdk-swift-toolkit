FeatureFormView(root: featureForm!, isPresented: featureFormViewIsPresented)
    .navigationDisabled(...)
    .onFeatureFormChanged { featureForm in
        ...
    }
    .onFormEditingEvent { editingEvent in
        switch editingEvent {
        case .discardedEdits(let willNavigate):
            ...
        case .savedEdits(let willNavigate):
            ...
        }
    }
