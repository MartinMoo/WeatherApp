//
//  FavoriteLocation+CoreDataProperties.swift
//  assignment
//
//  Created by Moo Maa on 25/01/2021.
//
//

import Foundation
import CoreData


extension FavoriteLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteLocation> {
        return NSFetchRequest<FavoriteLocation>(entityName: "FavoriteLocation")
    }

    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}

extension FavoriteLocation : Identifiable {

}
