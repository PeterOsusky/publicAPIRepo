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
        return !NetworkMonitor.shared.isConnected
    }
    
    private func startLoading() {
        isLoading = true
    }

    private func stopLoading() {
        isLoading = false
    }
    
    func fetchApis(query: String? = nil) {
        var url = URL(string: "https://api.publicapis.org/entries")!
        
        if let query = query {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "title", value: query)]
            url = components.url!
        }
        
        self.startLoading()
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.stopLoading()
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    self.apis = []
                    self.hasResults = false
                }
            }, receiveValue: { [weak self] response in
                self?.apis = response.entries ?? []
                self?.hasResults = !(self?.apis.isEmpty ?? true)
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
