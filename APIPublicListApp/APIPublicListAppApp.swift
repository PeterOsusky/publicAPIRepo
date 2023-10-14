//
//  APIPublicListAppApp.swift
//  APIPublicListApp
//
//  Created by Peter on 13/10/2023.
//

import SwiftUI

@main
struct APIPublicListAppApp: App {
    let coreDataModel = CoreDataModel()

    var body: some Scene {
        WindowGroup {
            APIListView()
                .environment(\.managedObjectContext, coreDataModel.container.viewContext)
        }
    }
}
