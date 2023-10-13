//
//  APISearchService.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import Combine

class ApiSearchService: ObservableObject {
    @Published var apis: [APIModel] = []
    @Published var categories: [String] = []

    var cancellables: Set<AnyCancellable> = []
    
    func fetchApis() {
        let url = URL(string: "https://api.publicapis.org/entries")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Handle error here
            }, receiveValue: { [weak self] response in
                self?.apis = response.entries
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
    let entries: [APIModel]
}

struct CategoryResponse: Codable {
    let categories: [String]
}
