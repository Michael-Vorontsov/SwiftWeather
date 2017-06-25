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
  defaultRemoteHost : "http://api.worldweatheronline.com/premium/v1",
  
//  defaultRemoteHost : "http://api.worldweatheronline.com/free/v2",
  defaultAccessKey : "33b2ec022d08499d80b155031172506"
)

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, DataPresenter, DataRequestor {
  
  static var sharedAppDelegate:AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  var window: UIWindow?
  
  var dataOperationManager: DataRetrievalOperationManager!
  var coreDataManager: CoreDataManager!
  var objectBuilder: ObjectBuilder!
  
  
  
//  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    var appControllerContext = [String : String]()
    if let launchOptions = launchOptions {
      for (kind, value) in launchOptions {
        if let value = value as? String {
          appControllerContext[kind.rawValue] = value
        }
      }
    }
    

    // Setup internal services
    /*
     
     Defalut values provided as constants, however database parameters and enpoint can be customized through Launch options, for example to run UI tests on custom envoronment
     */
    let databaseName: String = appControllerContext[Consts.launchKeys.databaseName] ?? Consts.defaultDatabaseName
    
    let modelName = appControllerContext[Consts.launchKeys.databaseModel]  ?? Consts.defaultDatabaseModel
    coreDataManager = CoreDataManager(databaseName: databaseName, modelName: modelName)
    
    let remoteHost = appControllerContext[Consts.launchKeys.remoteHost] ?? Consts.defaultRemoteHost
    let accessKey = appControllerContext[Consts.launchKeys.accessKey] ?? Consts.defaultAccessKey
    
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
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    refreshCurrentRegionForecast()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    coreDataManager?.backContext().save(recursive: true)
  }
  
}

extension AppDelegate {
  func refreshCurrentRegionForecast() {
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

