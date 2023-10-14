//
//  APISearchService.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import Combine
import Network

class ApiSearchService: ObservableObject {
    @Published var apis: [APIModel] = []
    @Published var categories: [String] = []
    @Published var isLoading: Bool = false
    @Published var hasResults: Bool = true

    var cancellables: Set<AnyCancellable> = []
    
    
    var isOfflineMode: Bool {
        // Negate isConnected because isOfflineMode should be true when isConnected is false
        return !NetworkMonitor.shared.isConnected
    }
    
    func fetchApis(query: String? = nil) {
        var url = URL(string: "https://api.publicapis.org/entries")!
        
        if let query = query {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "title", value: query)]
            url = components.url!
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false  // Set loading state to false when fetching is complete
                
                switch completion {
                case .finished:
                    break // Finished successfully
                case .failure(let error):
                    print("Error fetching data: \(error)") // Handle the error
                }
            }, receiveValue: { [weak self] response in
                self?.apis = response.entries!
                self?.hasResults = !response.entries!.isEmpty // Set hasResults based on whether any entries were received
            })
            .store(in: &cancellables)
    }
    
    func fetchCategories() {
        let url = URL(string: "https://api.publicapis.org/categories")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CategoryResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle error here
            }, receiveValue: { [weak self] response in
                self?.categories = response.categories
            })
            .store(in: &cancellables)
    }
}

struct APIResponse: Codable {
    let entries: [APIModel]?
}

struct CategoryResponse: Codable {
    let categories: [String]
}
