//
//  CoreDataManager.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataError : Int {
  case unknown = 1000
  case storeCoordinatorCreation
  case savingChanges
}

private let Consts = (
  errorDomain : "error.weather.database",
  // Tuples expect to have at leasst 2 keypairs
  placeholder : false
)

/**
 Protocol for any object designated to work with core data.
 */
public protocol DataPresenter:NSObjectProtocol {
  var coreDataManager: CoreDataManager! {get set}
}

/**
 Class responsible for storing and retriving data from local database
 */
open class CoreDataManager: NSObject {
  
  /**
   CoreDataManager error domain
   */
  static let errorDomain = Consts.errorDomain
  
  /**
   Init CoreDataManager with specified database name
   */
  public init(databaseName: String, modelName: String, bundle:Bundle = Bundle.main) {
    self.databaseName = databaseName
    dataModel = modelName
    modelBundle = bundle
    super.init()
  }
  
  /**
   NSManagedObject context dedicated for UI operations working on main thread
   */
  open lazy var mainContext: NSManagedObjectContext = {
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.parent = self.persistentContext
    return managedObjectContext
  }()
  
  /**
   NSManagedObject context dedicated for synchronous data parsing operations working on background thread
   */
  open lazy var dataContext: NSManagedObjectContext = {
    return self.backContext()
  }()
  
  /**
   Creating separate background context to above main context to perfrom backgound data operations
   */
  open func backContext() -> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    managedObjectContext.parent = self.mainContext
    return managedObjectContext
  }
  
  /**
   Delete sqlite database file from disk
   */
  open func wipeDatabase(reloadStores:Bool = true) {
    do {
      for store in persistentStoreCoordinator.persistentStores {
        let storeURL = store.url!
        try persistentStoreCoordinator.remove(store)
        _ = try FileManager.default.removeItem(at: storeURL)
      }
      
      persistentContext.reset()
      mainContext.reset()
      if true == reloadStores {
        let url = FileManager.applicationDocumentsDirectory.appendingPathComponent("\(self.databaseName).sqlite")
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
      }
    } catch {
      print("Error occured while trying to wipe persistent store")
      assert(false)
    }
  }

  // MARK: - Private methods
  
  fileprivate let databaseName: String
  fileprivate let dataModel: String
  fileprivate let modelBundle: Bundle
  
  open fileprivate(set) lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = self.modelBundle.url(forResource: self.dataModel, withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)
    return model!
  }()
  
  open fileprivate(set)  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = FileManager.applicationDocumentsDirectory.appendingPathComponent("\(self.databaseName).sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: CoreDataManager.errorDomain, code: CoreDataError.storeCoordinatorCreation.rawValue, userInfo: dict)
      print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      
      // If error - try to delete database and create it from scratch
      do {
        try FileManager.default.removeItem(at: url)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
      } catch {
        print("Error occured while trying recreate database")
        abort();
      }
    }
    return coordinator
  }()
  
  /**
   Private context working in background thread with persisten store directly
   */
  fileprivate lazy var persistentContext: NSManagedObjectContext = {
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
}
