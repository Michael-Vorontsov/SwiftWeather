//
//  Region+CoreDataProperties.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Region {

    @NSManaged var isCurrent: NSNumber?
    @NSManaged var name: String?
    @NSManaged var timeZone: String?
    @NSManaged var isSelected: NSNumber?
    @NSManaged var currectCondition: WeatherCondition?
    @NSManaged var forecasts: NSSet?

}
