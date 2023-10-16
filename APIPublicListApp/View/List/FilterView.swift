//
//  FilterView.swift
//  APIPublicListApp
//
//  Created by Peter on 16/10/2023.
//

import Foundation
import SwiftUI

struct FilterView: View {
    @ObservedObject var apiService: ApiSearchService
    @ObservedObject var searchModel: ApiViewModel
    
    var body: some View {
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
        }
    }
}
