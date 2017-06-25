//
//  GeosearchOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import DataRetrievalKit
@testable import SwiftWeather

class GeosearchOperationTests: XCTestCase {
  
  var operationManager:DataRetrievalOperationManager!
  var dataManager: CoreDataManager!
  
  override func setUp() {
    super.setUp()
    if nil == operationManager {
      operationManager = DataRetrievalOperationManager(
        remote:"http://api.worldweatheronline.com/free/v2",
        accessKey: "bdaaf16df2e9ef7eb6f4e40e5f51e83efee4cb3c"
      )
      
      
      dataManager = CoreDataManager(databaseName:"TestDB", modelName: "SwiftWeather")
      operationManager.coreDataManager = dataManager
      operationManager.objectBuilder = ObjectBuilder(dataManager:dataManager)
    }
  }

  func testGeoOperation() {
    let operation = GeosearchDataOperation(request: "London")
    XCTAssertNotNil(operation)
    let exp = expectation(description: "Operation expectation")
    operationManager.addOperations([operation]) { (success, results,  errors) in
      XCTAssertTrue(success)
      XCTAssertGreaterThan(results.count, 0)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
    
  }
  
}
