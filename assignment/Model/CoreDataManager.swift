//
//  CoreDataManager.swift
//  assignment
//
//  Created by Martin Miklas on 25/01/2021.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed: \(error)")
            }
        }
        return container
    }()
    
    func addLocation(name: String, longitude: Double, latitude: Double) {
        let context = persistentContainer.viewContext
        let location = NSEntityDescription.insertNewObject(forEntityName: "FavoriteLocation", into: context)
        
        location.setValue(name, forKey: "name")
        location.setValue(longitude, forKey: "longitude")
        location.setValue(latitude, forKey: "latitude")
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save context with location: \(error)")
        }
    }
    
    func fetchLocationList() -> [FavoriteLocation] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        do {
            let locationList = try context.fetch(fetchRequest)
            return locationList
        } catch let error {
            print("Failed to fetch: \(error)")
            return[]
        }
    }
    
    func isEntityEmpty(entity: String) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            return results.count == 0
        } catch let error {
            print("Failed to fetch: \(error)")
            return true
        }
    }
    
    func deleteLocation(name: String) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        
        do {
            let locationList = try context.fetch(fetchRequest)
            locationList.forEach { (fetchedLocation) in
                if fetchedLocation.name == name {
                    context.delete(fetchedLocation)
                }
            }
            do {
                try context.save()
            } catch let error {
                print("Failed to save context: \(error)")
            }
        } catch let error {
            print("Failed to fetch or delete location from context: \(error)")
        }
        
    }
}
