//
//  DailyForecast+CoreDataProperties.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DailyForecast {

    @NSManaged var date: NSDate?
    @NSManaged var maxTemp: NSNumber?
    @NSManaged var minTemp: NSNumber?
    @NSManaged var sunrise: NSDate?
    @NSManaged var sunset: NSDate?
    @NSManaged var hourly: NSSet?
    @NSManaged var region: Region?

}
