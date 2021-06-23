// Copyright 2021 Esri.

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

/// Defines how many results to return; one, many, or automatic based on circumstance.
public enum SearchResultMode {
    /// Search should always result in at most one result.
    case single
    /// Search should always try to return multiple results.
    case multiple
    /// Search should make a choice based on context. E.g. 'coffee shop' should be multiple results,
    /// while '380 New York St. Redlands' should be one result.
    case automatic
}

/// Performs searches and manages search state for a Search, or optionally without a UI connection.
public struct SearchViewModel {
    /// The string shown in the search view when no user query is entered.
    /// Default is "Find a place or address", or read from web map JSON if specified in the web map configuration.
    var defaultPlaceHolder: String = "Find a place or address"
    
    /// Tracks the currently active search source.  All sources are used if this property is `nil`.
    var activeSource: SearchSourceProtocol?
    
    /// Tracks the current user-entered query. This should be updated by the view after every key press.
    /// This property drives both suggestions and searches. This property can be changed by
    /// other method calls and property changes within the view model, so the view should take care to
    /// observe for changes.
    @State var currentQuery: String?
    
    /// The search area to be used for the current query. Ignored in most queries, unless the
    /// `RestrictToArea` property is set to true when calling `CommitSearch`. This property
    /// should be updated as the user navigates the map/scene, or at minimum before calling `CommitSearch`.
    var queryArea: Geometry?
    
    /// Defines the center for the search. This should be updated by the view every time the
    /// user navigates the map.
    var queryCenter: Point?
    
    /// Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
    /// number of results is returned based on the type of suggestion chosen (driven by the IsCollection property).
    var resultMode: SearchResultMode
    
    /// Collection of results. `nil` means no query has been made. An empty array means there
    /// were no results, and the view should show an appropriate 'no results' message.
    var results: [SearchResult]?
    
    /// Tracks selection of results from the `results` collection. When there is only one result,
    /// that result is automatically assigned to this property. If there are multiple results, the view sets
    /// this property upon user selection. This property is observable. The view should observe this
    /// property and update the associated GeoView's viewpoint, if configured.
    @State var selectedResult: SearchResult?
    
    /// Collection of search sources to be used. This list is maintained over time and is not nullable.
    /// The view should observe this list for changes. Consumers should add and remove sources from
    /// this list as needed.
    @State var sources: [SearchSourceProtocol] = []
    
    /// Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
    /// are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
    /// a useful 'no results' message should be shown by the view.
    var suggestions: [SearchSuggestion]?
    
    /// True if the `QueryArea` has changed since the `Results` collection has been set.
    /// This property is used by the view to enable 'Repeat search here' functionality. This property is
    /// observable, and the view should use it to hide and show the 'repeat search' button. Changes to
    /// this property are driven by changes to the `QueryArea` property.
    @State var isEligibleForRequery: Bool = false
    
    /// Starts a search. `SelectedResult` and `Results`, among other properties, are set
    /// asynchronously. Other query properties are read to define the parameters of the search.
    /// Participates in cooperative cancellation using the supplied cancellation token.
    /// If `restrictToArea` is true, only results in the query area will be returned.
    /// - Parameter restrictToArea: If true, the search is restricted to results within the extent
    /// of the `QueryArea` property. Behavior when called with `RestrictToArea` set to true
    /// when the `QueryArea` property is null, a line, a point, or an empty geometry is undefined.
    func commitSearch(_ restrictToArea: Bool) async {
        
    }
    
    /// Updates suggestions list asynchronously. View should take care to cancel previous suggestion
    /// requests before initiating new ones. The view should also wait for some time after user finishes
    /// typing before making suggestions. The JavaScript implementation uses 150ms by default.
    /// - Parameter cancellationToken: Token used for cooperative cancellation.
    func updateSuggestions(_ cancellationToken: String?) async {
        
    }
    
    /// Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
    /// generally the same as `CommitSearch`, except the suggestion is used instead of the
    /// `CurrentQuery` property. When a suggestion is accepted, `CurrentQuery` is updated to
    /// match the suggestion text. The view should take care not to submit a separate search in response
    /// to changes to `CurrentQuery` initiated by a call to this method.
    /// - Parameters:
    ///   - searchSuggestion: The suggestion to use to commit the search.
    ///   - cancellationToken: ken used for cooperative cancellation.
    func accesptSuggestion(_ searchSuggestion: SearchSuggestion,
                           cancellationToken: String?) async {
        
    }
    
    /// Configures the view model for the provided map. By default, will only configure the view model
    /// with the default world geocoder. In future updates, additional functionality may be added to take
    /// web map configuration into account.
    /// - Parameters:
    ///   - map: Map to use for configuration.
    ///   - cancellationToken: cancellationToken: String
    func configureForMap(_ map: Map, cancellationToken: String?) {
        
    }
    
    /// Configures the view model for the provided scene. By default, will only configure the view model
    /// with the default world geocoder. In future updates, additional functionality may be added to take
    /// web scene configuration into account.
    /// - Parameters:
    ///   - scene: Scene used for configuration.
    ///   - cancellationToke: Token used for cooperative cancellation.
    func configureForScene(_ scene: ArcGIS.Scene, cancellationToken: String?) {
        
    }
    
    /// Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
    /// and reset the current query.
    func clearSearch() {
        
    }
}
