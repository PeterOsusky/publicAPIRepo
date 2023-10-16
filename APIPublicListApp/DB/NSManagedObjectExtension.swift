//
//  NSManagedObjectExtension.swift
//  APIPublicListApp
//
//  Created by Peter on 16/10/2023.
//

import CoreData

public extension NSManagedObject {
    convenience init(usedContext: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext)!
        self.init(entity: entity, insertInto: usedContext)
    }
}
