//
//  NSManagedObject+Extensions.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

protocol NamedManagedObject {
  static var entityName: String {get}
  init?(context:NSManagedObjectContext)
}

extension NamedManagedObject where Self: NSManagedObject {
  
  static var entityName:String {
    return NSStringFromClass(Self).componentsSeparatedByString(".").last ?? ""
  }
  
  init?(context:NSManagedObjectContext) {
    guard let newObject = (NSEntityDescription.insertNewObjectForEntityForName(Self.entityName, inManagedObjectContext: context)) as? Self else {
      return nil
    }
    self = newObject
  }
  
  static func allObjects(context:NSManagedObjectContext) -> [Self]? {
    let request = NSFetchRequest(entityName: Self.entityName)
    return (try? context.executeFetchRequest(request)) as? [Self]
  }
  
}
