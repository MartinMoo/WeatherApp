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
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
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
    
    func deleteLocation(lat: Double, long: Double) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        fetchRequest.predicate = NSPredicate(format: "(latitude == %@) AND (longitude == %@)", lat as NSNumber, long as NSNumber)
        
        do {
            let locationsToRemove = try context.fetch(fetchRequest) as [NSManagedObject]
            locationsToRemove.forEach { (locationToRemove) in
                context.delete(locationToRemove)
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
    
    func locationExists(name: String, lat: Double, long: Double) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        print(name)
        fetchRequest.predicate = NSPredicate(format: "(name == %@) OR (latitude == %@) AND (longitude == %@)",name as NSString, lat as NSNumber, long as NSNumber)
        
        var results: [NSManagedObject] = []

        do {
            results = try context.fetch(fetchRequest) as [NSManagedObject]
        } catch let error {
            print("Error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
}
