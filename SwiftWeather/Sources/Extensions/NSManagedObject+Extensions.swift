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
  
  static var entityName: String { get }

  // Similar to iOS10 init?(context:)
  init?(managedContext:NSManagedObjectContext)
}

extension NamedManagedObject where Self: NSManagedObject {

  static var entityName:String {
    return NSStringFromClass(Self.self).components(separatedBy: ".").last ?? ""
  }
  
  init?(managedContext:NSManagedObjectContext) {
    guard let newObject = (NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: managedContext)) as? Self else {
      return nil
    }
    self = newObject
  }
  
  static func allObjects(_ context:NSManagedObjectContext) -> [Self]? {
    let request = NSFetchRequest<Self>(entityName: Self.self.entityName )
    return (try? context.fetch(request))
  }
  
}
