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
        
        apiService.$apis
            .combineLatest($searchQuery, $selectedCategory)
            .map { apis, query, category -> [APIModel] in
                return self.filterApis(apis, query: query, category: category)
            }
            .assign(to: &$filteredApis)
        
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { queryString in
                if !queryString.isEmpty, !self.apiService.isOfflineMode {
                    // Perform online search if needed
                    self.apiService.fetchApis(query: queryString)
                }
            }
            .store(in: &apiService.cancellables)
    }
    
    private func filterApis(_ apis: [APIModel], query: String, category: String) -> [APIModel] {
        var filtered = apis
        
        if !query.isEmpty {
            filtered = filtered.filter { $0.API.contains(query) || $0.Description.contains(query) }
        }
        
        if category != "All" {
            filtered = filtered.filter { $0.Category == category }
        } else {
            filtered = Array(filtered.prefix(40))
        }
        
        return filtered
    }
}
