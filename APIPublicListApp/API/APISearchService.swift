//
//  APISearchService.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import Combine
import Network
import CoreData

class ApiSearchService: ObservableObject {
    @Published var apis: [APIModel] = []
    @Published var categories: [String] = []
    @Published var isLoading: Bool = false
    @Published var hasResults: Bool = true
    @Published var coreDataModel = CoreDataModel()

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
        guard !isOfflineMode else {
            fetchFromCoreData()
            return
        }
        let url = URL(string: "https://api.publicapis.org/entries")!
        
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
                    self.fetchFromCoreData()
                    print("offline")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                self.apis = response.entries ?? []
                self.hasResults = !self.apis.isEmpty
                
                self.saveToCoreData(apiData: Array(self.apis.prefix(40)))
                print("online")

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
    
    func saveToCoreData(apiData: [APIModel]) {
        let context = coreDataModel.container.viewContext
        
        let fetchRequest: NSFetchRequest<ApiDBEntity> = ApiDBEntity.fetchRequest()

        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            for entity in fetchedEntities {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error deleting old records from CoreData: \(error)")
        }

        for api in apiData.prefix(40) {
            let entity = ApiDBEntity(context: context)
            entity.apiName = api.API
            entity.apiDescription = api.Description
            entity.apiAuth = api.Auth
            entity.apiHTTPS = api.HTTPS
            entity.apiCategory = api.Category
            entity.apiLink = api.Link
        }
        do {
            try context.save()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
    }
    
    private func fetchFromCoreData() {
        let context = coreDataModel.container.viewContext
        let fetchRequest: NSFetchRequest<ApiDBEntity> = ApiDBEntity.fetchRequest()
        
        do {
            let storedApis = try context.fetch(fetchRequest)
            
            self.apis = storedApis.compactMap { storedApi in
                guard let title = storedApi.apiName,
                      let descriptionText = storedApi.apiDescription,
                      let auth = storedApi.apiAuth,
                      let category = storedApi.apiCategory,
                      let link = storedApi.apiLink
                else {
                    return nil
                }
                let https = storedApi.apiHTTPS
                
                return APIModel(API: title,
                                Description: descriptionText,
                                Auth: auth,
                                Link: link,
                                Category: category,
                                HTTPS: https)
            }
            
            self.hasResults = !self.apis.isEmpty
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
}

struct APIResponse: Codable {
    let entries: [APIModel]?
}

struct CategoryResponse: Codable {
    let categories: [String]
}
