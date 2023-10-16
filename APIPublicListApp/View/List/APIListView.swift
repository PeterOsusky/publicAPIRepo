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
                
                HStack {
                    TextField("Search APIs...", text: $searchModel.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .trailing], 8)
                        .autocorrectionDisabled()
                    Button(action: {
                        apiService.fetchApis()
                        searchModel.searchQuery = ""
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 8)
                }
                
                Picker("Categories", selection: $searchModel.selectedCategory) {
                    Text("All").tag("All")
                    ForEach(apiService.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if apiService.isLoading {
                    ProgressView("Loading APIs...")
                    Spacer()
                }
                else if searchModel.filteredApis.isEmpty {
                    Text("No APIs found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Spacer()
                }
                else {
                    List(searchModel.filteredApis) { api in
                        NavigationLink(destination: APIDetailView(url: api.Link)) {
                            APIRowView(api: api)
                        }
                        .isDetailLink(true)
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
