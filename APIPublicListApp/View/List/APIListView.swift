//
//  ContentView.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import SwiftUI

struct APIListView: View {
    @ObservedObject var apiService = ApiSearchService()
    @ObservedObject var searchModel: ApiSearchModel
    
    init() {
        let apiService = ApiSearchService()
        self.apiService = apiService
        self.searchModel = ApiSearchModel(apiService: apiService)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Categories", selection: $searchModel.selectedCategory) {
                    Text("All").tag("All")
                    ForEach(apiService.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                List(searchModel.filteredApis, id: \.API) { api in
                    NavigationLink(destination: APIDetailView(url: api.Link)) {
                        APIRow(api: api)
                    }
                }
            }
            .navigationTitle("API List")
        }
        .onAppear {
            apiService.fetchApis()
            apiService.fetchCategories()
        }
    }
}

struct APIListView_Previews: PreviewProvider {
    static var previews: some View {
        APIListView()
    }
}
