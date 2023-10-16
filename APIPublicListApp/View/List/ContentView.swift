//
//  ContentView.swift
//  APIPublicListApp
//
//  Created by Peter on 16/10/2023.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var apiService: ApiSearchService
    @ObservedObject var searchModel: ApiViewModel
    
    var body: some View {
        VStack {
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
    }
}
