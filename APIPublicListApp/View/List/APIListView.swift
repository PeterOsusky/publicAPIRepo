//
//  ContentView.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import SwiftUI

struct APIListView: View {
    @ObservedObject var apiService = ApiSearchService()
    @ObservedObject var searchModel: ApiViewModel
    
    init() {
        let apiService = ApiSearchService()
        self.apiService = apiService
        self.searchModel = ApiViewModel(apiService: apiService)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                FilterView(apiService: apiService, searchModel: searchModel)
                ContentView(apiService: apiService, searchModel: searchModel)
                Spacer()
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
