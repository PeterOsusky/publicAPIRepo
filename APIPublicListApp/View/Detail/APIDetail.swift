//
//  APIDetail.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation
import SwiftUI

struct APIDetailView: View {
    let url: String
    var body: some View {
        WebView(url: url)
            .navigationTitle("API Detail")
    }
}
