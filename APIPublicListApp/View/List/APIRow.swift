//
//  APIRow.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import SwiftUI

struct APIRow: View {
    var api: APIModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(api.API).font(.headline)
                Text(api.Description).font(.subheadline)
                Text("Category: \(api.Category)")
                Text(api.HTTPS ? "HTTPS" : "")
            }
            Spacer()
            Image(systemName: api.Auth.isEmpty ? "lock.open" : "lock")
        }
        .padding()
    }
}
