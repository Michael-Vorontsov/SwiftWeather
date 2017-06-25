//
//  ObjectBuilder.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

public enum BuilderErrors:Error {
  case noContextAvailable
  case coreDataError
  case remoteError(errorInfo:AnyObject)
  case wrongData(dataInfo:[String : AnyObject])
  case incompleteData
}

/**
 Class represents builder for NSManagedObjects.
 
 Each creation of each managed object determine by specific extensions of builder.
 ManagedObject DataRetrieval operation contains builder with coreDataManager injected in it by OperationManager, and
 specific builder selector to be called determine by specific subclass.
 */
open class ObjectBuilder: NSObject, DataPresenter {
  
  open var coreDataManager: CoreDataManager!
  
  public init(dataManager:CoreDataManager) {
    coreDataManager = dataManager
    super.init()
  }
  
}
