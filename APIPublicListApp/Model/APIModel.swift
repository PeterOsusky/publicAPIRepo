//
//  APISearchService.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import Foundation

struct APIModel: Codable, Identifiable {
    let id = UUID()
    let API, Description, Auth, Link, Category: String
    let HTTPS: Bool
    
    enum CodingKeys: String, CodingKey {
        case API, Description, Auth, Link, Category, HTTPS
    }
}
