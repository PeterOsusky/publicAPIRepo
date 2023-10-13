//
//  APIViewModel.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import Combine

class ApiViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var selectedCategory: String = "All"
    @Published var filteredApis: [APIModel] = []
    
    private var apiService: ApiSearchService
    
    init(apiService: ApiSearchService) {
        self.apiService = apiService
        
        // Observer for API list changes
        apiService.$apis
            .combineLatest($searchQuery, $selectedCategory)
            .map { apis, query, category -> [APIModel] in
                var filtered = apis
                
                // If a search query is present, filter based on it
                if !query.isEmpty {
                    filtered = filtered.filter { $0.API.contains(query) || $0.Description.contains(query) }
                }
                
                // If a category is selected (not "All"), filter based on it
                if category != "All" {
                    filtered = filtered.filter { $0.Category == category }
                } else {
                    filtered = Array(filtered.prefix(40))
                }
                
                return filtered
            }
            .assign(to: &$filteredApis)
    }
}
