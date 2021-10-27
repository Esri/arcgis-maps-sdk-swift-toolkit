***REMOVED***
***REMOVED***  SwiftUIView.swift
***REMOVED***  
***REMOVED***
***REMOVED***  Created by Mark Dostal on 10/27/21.
***REMOVED***

***REMOVED***

struct SearchField: View {
***REMOVED***let defaultPlaceholder: String
***REMOVED***var currentQuery: Binding<String>
***REMOVED***let isShowResultsHidden: Bool
***REMOVED***var showResults: Binding<Bool>
***REMOVED***var onSubmit: () -> Void = {***REMOVED***

***REMOVED***internal init(
***REMOVED******REMOVED***defaultPlaceholder: String = "",
***REMOVED******REMOVED***currentQuery: Binding<String>,
***REMOVED******REMOVED***isShowResultsHidden: Bool,
***REMOVED******REMOVED***showResults: Binding<Bool>,
***REMOVED******REMOVED***onSubmit: @escaping () -> Void = {***REMOVED***
***REMOVED***) {
***REMOVED******REMOVED***self.defaultPlaceholder = defaultPlaceholder
***REMOVED******REMOVED***self.currentQuery = currentQuery
***REMOVED******REMOVED***self.isShowResultsHidden = isShowResultsHidden
***REMOVED******REMOVED***self.showResults = showResults
***REMOVED******REMOVED***self.onSubmit = onSubmit
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED*** Search button
***REMOVED******REMOVED******REMOVED***Button(
***REMOVED******REMOVED******REMOVED******REMOVED***action: onSubmit,
***REMOVED******REMOVED******REMOVED******REMOVED***label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(uiColor: .opaqueSeparator))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)

***REMOVED******REMOVED******REMOVED******REMOVED*** Search text field
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***defaultPlaceholder,
***REMOVED******REMOVED******REMOVED******REMOVED***text: currentQuery
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { onSubmit() ***REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED*** Delete text button
***REMOVED******REMOVED******REMOVED***if !currentQuery.wrappedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action: { currentQuery.wrappedValue = "" ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.opaqueSeparator))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED*** Show Results button
***REMOVED******REMOVED******REMOVED***if !isShowResultsHidden {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action: { showResults.wrappedValue.toggle() ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "eye")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(!showResults.wrappedValue ? .none : .slash)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(.fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.opaqueSeparator))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
