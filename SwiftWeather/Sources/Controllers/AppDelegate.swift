//
//  AppDelegate.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData
import DataRetrievalKit

private let Consts = (
  launchKeys : (
    databaseName : "db_name",
    databaseModel : "db_model",
    remoteHost: "remote_host",
    accessKey: "access_key"
  ),
  defaultDatabaseName : "SwiftWeather",
  defaultDatabaseModel : "SwiftWeather",
  defaultRemoteHost : "http://api.worldweatheronline.com/free/v2",
  defaultAccessKey : "bdaaf16df2e9ef7eb6f4e40e5f51e83efee4cb3c"
)

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, DataPresenter, DataRequestor {
  
  static var sharedAppDelegate:AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  
  var window: UIWindow?
  
  var dataOperationManager: DataRetrievalOperationManager!
  var coreDataManager: CoreDataManager!
  var objectBuilder: ObjectBuilder!
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Setup internal services
    let databaseName = launchOptions?[Consts.launchKeys.databaseName] as? String ?? Consts.defaultDatabaseName
    let modelName = launchOptions?[Consts.launchKeys.databaseModel] as? String ?? Consts.defaultDatabaseModel
    coreDataManager = CoreDataManager(databaseName: databaseName, modelName: modelName)
    
    let remoteHost = launchOptions?[Consts.launchKeys.remoteHost] as? String ?? Consts.defaultRemoteHost
    let accessKey = launchOptions?[Consts.launchKeys.accessKey] as? String ?? Consts.defaultAccessKey
    
    dataOperationManager = DataRetrievalOperationManager(remote: remoteHost, accessKey: accessKey)
    dataOperationManager.coreDataManager = coreDataManager

    objectBuilder = ObjectBuilder(dataManager:coreDataManager)
    dataOperationManager.objectBuilder = objectBuilder
    
    // Setup root view controller
    
    if let viewController = window?.rootViewController as? DataRequestor {
      viewController.dataOperationManager = dataOperationManager
    }
    if let viewController = window?.rootViewController as? DataPresenter {
      viewController.coreDataManager = coreDataManager
    }

    //Setup appearance
    AppearanceScheme.setupApperance()
    
    return true
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    refreshCurrentRegionForecast()
  }
  
  func applicationWillTerminate(application: UIApplication) {
    coreDataManager?.backContext().save(recursive: true)
  }
  
}

extension AppDelegate {
  func refreshCurrentRegionForecast() {
    return
    
    let operation = CurrentLocationOperation()
    dataOperationManager.addOperations([operation]) {[weak self] (success, results, errors) in
      guard true == success, let regionId = results.first as? NSManagedObjectID else {
        return
      }
      
      let operation  = ForecastDataOperation(regionIdentifier:regionId )
      self?.dataOperationManager.addOperations([operation])
    }
  }
  
}

