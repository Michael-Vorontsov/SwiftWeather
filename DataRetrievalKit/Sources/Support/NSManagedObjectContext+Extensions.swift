//
//  NSManagedObjectContext+Extensions.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 13/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
  /**
   Flush changes in givven context thtough all parent context to persistent store.
   */
  public func save (recursive:Bool) {
    if self.hasChanges {
      do {
        try self.save()
        if let parentContext = parent, true == recursive {
          parentContext.save(recursive:true)
        }
      } catch {
        var dict = [String: AnyObject]()
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: CoreDataManager.errorDomain, code: CoreDataError.storeCoordinatorCreation.rawValue, userInfo: dict)
        print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        assert(false)
      }
    }
  }
  
  public func deleteObjects(_ arrayOfObjects:[NSManagedObject]) {
    for managedObject in arrayOfObjects {
      self.delete(managedObject)
    }
  }
  
}

