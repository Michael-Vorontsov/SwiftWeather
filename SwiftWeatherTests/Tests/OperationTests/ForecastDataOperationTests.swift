//
//  ForecastDataOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import CoreData
import DataRetrievalKit
@testable import SwiftWeather

class ForecastDataOperationTests: XCTestCase {
  
  var operationManager:DataRetrievalOperationManager!
  var dataManager: CoreDataManager!

  override func setUp() {
    super.setUp()
    if nil == operationManager {
      operationManager = DataRetrievalOperationManager(remote:"http://api.worldweatheronline.com/free/v2",
                                                       accessKey: "bdaaf16df2e9ef7eb6f4e40e5f51e83efee4cb3c")
      
      
      dataManager = CoreDataManager(databaseName:"TestDB")
      operationManager.coreDataManager = dataManager
      operationManager.objectBuilder = ObjectBuilder(dataManager:dataManager)
    }
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    super.tearDown()
    
  }
  
  func testOperationByName() {
    let operation = ForecastDataOperation(regionName: "London")
    XCTAssertNotNil(operation)
    let exp = expectationWithDescription("Operation Exp.")
    operationManager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      XCTAssertNotNil(results)
      XCTAssertEqual(results.count, 1)
      XCTAssertNil(errors)
      exp.fulfill()
    }
    waitForExpectationsWithTimeout(30.0, handler: nil)
    
    guard let resultID = operation.results?.first as? NSManagedObjectID,
      let context = operationManager.coreDataManager?.mainContext,
      let region = context.objectWithID(resultID) as? Region
      else {
        XCTAssert(false)
        return
    }
    
    XCTAssertNotNil(region.name)
    let regionContainsLondon:Bool = (region.name?.containsString("London")) ?? false
    XCTAssertTrue(regionContainsLondon)
    XCTAssertNotNil(region.currectCondition)
    XCTAssertNotNil(region.currectCondition?.temperature)
    XCTAssertNotNil(region.currectCondition?.pressure)
    XCTAssertNotNil(region.currectCondition?.weatherDescription)
    XCTAssertNotNil(region.currectCondition?.windSpeed)
    XCTAssertNotNil(region.currectCondition?.windDirection)
    XCTAssertNotNil(region.forecasts)
  }
  
  func testOperationByRegion() {
    let regionToUpdate = Region(context: dataManager.mainContext)
    XCTAssertNotNil(regionToUpdate)
    regionToUpdate!.name = "Dublin"
    let operation = ForecastDataOperation(region: regionToUpdate!)
    
    XCTAssertNotNil(operation)
    let exp = expectationWithDescription("Operation Exp.")
    operationManager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      XCTAssertNotNil(results)
      XCTAssertEqual(results.count, 1)
      XCTAssertNil(errors)
      exp.fulfill()
    }
    waitForExpectationsWithTimeout(30.0, handler: nil)
    
    guard let resultID = operation.results?.first as? NSManagedObjectID,
      let context = operationManager.coreDataManager?.mainContext,
      let region = context.objectWithID(resultID) as? Region
      else {
        XCTAssert(false)
        return
    }
    
    XCTAssertNotNil(region.name)
    let regionContainsString:Bool = (region.name?.containsString("Dublin")) ?? false
    XCTAssertTrue(regionContainsString)
    XCTAssertNotNil(region.currectCondition)
    XCTAssertNotNil(region.currectCondition?.temperature)
    XCTAssertNotNil(region.currectCondition?.pressure)
    XCTAssertNotNil(region.currectCondition?.weatherDescription)
    XCTAssertNotNil(region.currectCondition?.windSpeed)
    XCTAssertNotNil(region.currectCondition?.windDirection)
    XCTAssertNotNil(region.forecasts)
  }

  func testOperationByRegionID() {
    let regionToUpdate = Region(context: dataManager.mainContext)
    XCTAssertNotNil(regionToUpdate)
    regionToUpdate!.name = "Paris"
    let operation = ForecastDataOperation(regionIdentifier: regionToUpdate!.objectID)
    
    XCTAssertNotNil(operation)
    let exp = expectationWithDescription("Operation Exp.")
    operationManager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      XCTAssertNotNil(results)
      XCTAssertEqual(results.count, 1)
      XCTAssertNil(errors)
      exp.fulfill()
    }
    waitForExpectationsWithTimeout(30.0, handler: nil)
    
    guard let resultID = operation.results?.first as? NSManagedObjectID,
      let context = operationManager.coreDataManager?.mainContext,
      let region = context.objectWithID(resultID) as? Region
      else {
        XCTAssert(false)
        return
    }
    
    XCTAssertNotNil(region.name)
    let regionContainsString:Bool = (region.name?.containsString("Paris")) ?? false
    XCTAssertTrue(regionContainsString)
    XCTAssertNotNil(region.currectCondition)
    XCTAssertNotNil(region.currectCondition?.temperature)
    XCTAssertNotNil(region.currectCondition?.pressure)
    XCTAssertNotNil(region.currectCondition?.weatherDescription)
    XCTAssertNotNil(region.currectCondition?.windSpeed)
    XCTAssertNotNil(region.currectCondition?.windDirection)
    XCTAssertNotNil(region.forecasts)
  }

}
