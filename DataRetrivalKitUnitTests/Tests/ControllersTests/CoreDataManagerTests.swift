//
//  CoreDataManagerTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 05/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import CoreData
import DataRetrievalKit


//
//  DataRetrivalKitUnitTests.swift
//  DataRetrivalKitUnitTests
//
//  Created by Mykhailo Vorontsov on 6/25/17.
//  Copyright © 2017 Mykhailo Vorontsov. All rights reserved.
//

import XCTest

//
//
//
class SampleManagedObject: NSManagedObject {

  @NSManaged var sid: NSNumber?
  @NSManaged var userId: NSNumber?
  @NSManaged var title: String?
  @NSManaged var body: String?
  // Insert code here to add functionality to your managed object subclass
  
}

//
class CoreDataManagerTests: XCTestCase {
  
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  var bundle: Bundle { return Bundle(for: type(of: self)) }
  

  func testCustomPersistentStore() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    let persistentStoreCoordinator = dataManager.mainContext.persistentStoreCoordinator!
    XCTAssertNotNil(persistentStoreCoordinator)
    XCTAssertEqual(persistentStoreCoordinator.persistentStores.count, 1)
    let persitentStore  = persistentStoreCoordinator.persistentStores.first;
    XCTAssertEqual(persitentStore?.url?.lastPathComponent, "TestDB.sqlite")
  }
  
  func testDefaultPersistentStore() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    let persistentStoreCoordinator = dataManager.mainContext.persistentStoreCoordinator!
    XCTAssertNotNil(persistentStoreCoordinator)
    XCTAssertEqual(persistentStoreCoordinator.persistentStores.count, 1)
    
    let persitentStore  = persistentStoreCoordinator.persistentStores.first;
    
    XCTAssertEqual(persitentStore?.url?.lastPathComponent, "TestDB.sqlite")
  }
  
  func testPersistentContext() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    let persistentContext = dataManager.mainContext.parent!
    XCTAssertNotNil(persistentContext)
    XCTAssertEqual(persistentContext.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    XCTAssertNil(persistentContext.parent)
  }
  
  func testMainContext() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    XCTAssertNotNil(dataManager);
    XCTAssertNotNil(dataManager.mainContext)
    XCTAssertEqual(dataManager.mainContext, dataManager.mainContext)
    XCTAssertEqual(dataManager.mainContext.concurrencyType, NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    let persistentContext = dataManager.mainContext.parent!
    XCTAssertNotNil(persistentContext)
  }
  
  func testDataContext() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    XCTAssertNotNil(dataManager);
    XCTAssertNotNil(dataManager.dataContext)
    XCTAssertEqual(dataManager.dataContext, dataManager.dataContext)
    XCTAssertEqual(dataManager.dataContext.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    XCTAssertEqual(dataManager.dataContext.parent, dataManager.mainContext)
  }
  
  func testBackContextFunc() {
    let dataManager = CoreDataManager(databaseName: "TestDB", modelName: "TestModel", bundle: bundle)
    XCTAssertNotNil(dataManager);
    let backContext1 = dataManager.backContext()
    XCTAssertNotNil(backContext1)
    XCTAssertNotEqual(backContext1, dataManager.dataContext)
    XCTAssertEqual(backContext1.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    XCTAssertEqual(backContext1.parent, dataManager.mainContext)
    XCTAssertNotEqual(backContext1, dataManager.backContext())
  }
  
  func testDBWipe() {
    
    let fileManager = FileManager.default
    
    let url = FileManager.applicationDocumentsDirectory.appendingPathComponent("TestDB-Wipe.sqlite")
    let filePath = url.relativePath
    XCTAssertNotNil(filePath)
    XCTAssertFalse(fileManager.fileExists(atPath: filePath))

    let bundle = Bundle(for: CoreDataManagerTests.self)
    let dataManager = CoreDataManager(databaseName: "TestDB-Wipe", modelName: "TestModel", bundle: bundle)

    XCTAssertNotNil(dataManager);
    
    let sampleObject = NSEntityDescription.insertNewObject(forEntityName: "SampleObject", into: dataManager.mainContext) as? SampleManagedObject
    
    XCTAssertNotNil(sampleObject)
    
    sampleObject?.title = "Some Title"
    dataManager.mainContext.save(recursive: true)
    XCTAssertTrue(fileManager.fileExists(atPath: filePath))
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SampleObject")
    let results = try? dataManager.mainContext.fetch(fetchRequest)

    XCTAssertNotNil(results)
    XCTAssertEqual(results?.count, 1)
    XCTAssertTrue(fileManager.fileExists(atPath: filePath))
    XCTAssertEqual(dataManager.mainContext.registeredObjects.count, 1)
    
    dataManager.wipeDatabase()
    
    XCTAssertEqual(dataManager.mainContext.registeredObjects.count, 0)
    XCTAssertTrue(fileManager.fileExists(atPath: filePath))
    let wipedResults = try? dataManager.mainContext.fetch(fetchRequest)
    XCTAssertNotNil(wipedResults)
    XCTAssertEqual(wipedResults?.count, 0)
    
    NSEntityDescription.insertNewObject(forEntityName: "SampleObject", into: dataManager.mainContext)
    dataManager.mainContext.save(recursive: true)

    dataManager.wipeDatabase(reloadStores:false)
    XCTAssertFalse(fileManager.fileExists(atPath: filePath))
  }
  
}
