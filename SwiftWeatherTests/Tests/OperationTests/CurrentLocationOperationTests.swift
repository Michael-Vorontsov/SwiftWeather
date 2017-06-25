//
//  DataRetrievalOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 25/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import DataRetrievalKit
@testable import SwiftWeather

class CurrentLocationOperationTests: XCTestCase {
  
  var dataRetrievalManager:DataRetrievalOperationManager!
  var dataManager: CoreDataManager!

  override func setUp() {
    super.setUp()
    if nil == dataRetrievalManager {
      dataRetrievalManager = DataRetrievalOperationManager()
      dataManager = CoreDataManager(databaseName:"Test", modelName: "SwiftWeather")
      dataRetrievalManager.coreDataManager = dataManager
      dataRetrievalManager.objectBuilder = ObjectBuilder(dataManager:dataManager)
    }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testOperation() {
    XCTAssertNotNil(dataRetrievalManager)
  }
  
  func testLocation() {
    XCTAssertNotNil(dataRetrievalManager)
    let operation = CurrentLocationOperation()
    let exp = expectation(description: "Operation exp");
    dataRetrievalManager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      XCTAssertNil(errors)
      XCTAssertNotNil(results)
      XCTAssertEqual(results.count, 1)
      
      if let result = results.first as? String {
        XCTAssertTrue(result.contains("London"))
      }
      exp.fulfill()
    }
    waitForExpectations(timeout: 30.0, handler: nil)
    XCTAssertNotNil(operation)
  }
  
}
