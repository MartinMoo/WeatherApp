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
    
    func addLocation(name: String, country: String, longitude: Double, latitude: Double) {
        let context = persistentContainer.viewContext
        let location = NSEntityDescription.insertNewObject(forEntityName: "FavoriteLocation", into: context)
        
        location.setValue(name, forKey: "name")
        location.setValue(longitude, forKey: "longitude")
        location.setValue(latitude, forKey: "latitude")
        location.setValue(country, forKey: "country")
        
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

    // Within one city only one marker
    func deleteLocation(name: String, country: String, lat: Double, long: Double) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        fetchRequest.predicate = NSPredicate(format: "((name == %@) AND (country == %@)) OR ((latitude == %@) AND (longitude == %@))", name as NSString, country as NSString, lat as NSNumber, long as NSNumber)
        
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
    
    // Within one city only one marker
    func locationExists(name: String, country: String, lat: Double, long: Double) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
        fetchRequest.predicate = NSPredicate(format: "((name == %@) AND (country == %@)) OR ((latitude == %@) AND (longitude == %@))",name as NSString, country as NSString, lat as NSNumber, long as NSNumber)
        
        var results: [NSManagedObject] = []

        do {
            results = try context.fetch(fetchRequest) as [NSManagedObject]
        } catch let error {
            print("Error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
}
