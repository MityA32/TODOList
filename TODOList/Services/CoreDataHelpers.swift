//
//  CoreDataHelpers.swift
//  TODOList
//
//  Created by Dmytro Hetman on 22.11.2022.
//

import Foundation
import CoreData

final class CoreDataService {
    
    lazy private var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoListModel")
        container.loadPersistentStores { _, error in
            //Handle error
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return container
    }()
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    private(set) static var shared: CoreDataService = .init()
    
    @discardableResult
    func create<T: NSManagedObject>(_ type: T.Type, _ handler: ((T) -> Void)?) -> T {
        let newObject = T(context: context)
        handler?(newObject)
        return newObject
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
    }
    
    func write(_ handler: () -> Void) {
        handler()
        saveContext()
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type) -> [T] {
        (try? context.fetch(type.fetchRequest()) as? [T]) ?? []
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
}


@propertyWrapper
class Fetch<T: NSManagedObject> {
    
    var wrappedValue: [T] {
        if let filter {
            return CoreDataService.shared.fetch(T.self).filter(filter)
        }
        return CoreDataService.shared.fetch(T.self)
    }
    
    var filter: ((T) -> (Bool))?
    
}
