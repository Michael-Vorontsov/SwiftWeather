//
//  WeatherCondition+CoreDataProperties.swift
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

extension WeatherCondition {

    @NSManaged var humidity: NSNumber?
    @NSManaged var pressure: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var time: Date?
    @NSManaged var weatherCode: NSNumber?
    @NSManaged var weatherDescription: String?
    @NSManaged var weatherIconPath: String?
    @NSManaged var weatherIconURL: String?
    @NSManaged var windDirection: NSNumber?
    @NSManaged var windSpeed: NSNumber?
    @NSManaged var forecast: DailyForecast?
    @NSManaged var region: Region?

}
