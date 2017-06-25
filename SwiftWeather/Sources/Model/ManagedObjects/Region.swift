//
//  Region.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

@objc(Region)
class Region: NSManagedObject, NamedManagedObject {
  
  static func selectedRegion(context: NSManagedObjectContext) -> Region? {
    let request = NSFetchRequest<Region>(entityName: Region.entityName)
    request.predicate = NSPredicate(format: "isSelected = %@", argumentArray: [true])
    let regions = try? context.fetch(request)
    return regions?.last
  }

}
