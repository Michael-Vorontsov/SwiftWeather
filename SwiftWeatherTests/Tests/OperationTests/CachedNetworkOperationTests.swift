//
//  CachedNetworkOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 12/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import DataRetrievalKit
import OHHTTPStubs
@testable import SwiftWeather

class CachedNetworkOperationTests: XCTestCase {
  
  var manager:DataRetrievalOperationManager! = nil
  
  override func setUp() {
    super.setUp()
    
    if nil == manager {
      manager = DataRetrievalOperationManager(remote:"http://stubbed_request.com")
      manager.accessKey = "some_key"
    }
    
    //Clear cache directory
    let fileManager = FileManager.default
    let cacheDirectory = FileManager.applicationCachesDirectory
    if  let content = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(rawValue: 0)) {
      for file in content {
        _ = try? fileManager.removeItem(at: file)
      }
    }
    
  }
  
  override func tearDown() {
    OHHTTPStubs.removeAllStubs()
    super.tearDown()
  }
  
  fileprivate func stubMock() {
    stub(condition: isHost("stubbed_request.com")) { _ in
      let jsonObject = ["key": 1]
      return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil).requestTime(0.1, responseTime: 0.1)
    }
  }
  
  fileprivate func stubError() {
    stub(condition: isHost("stubbed_request.com")) { _ in
      let jsonObject = ["error": 0]
      return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil).requestTime(0.1, responseTime: 0.1)
    }
  }
  
  func testOperationWithoutCache() {
    stubMock()
    let operation = CachedNetworkDataRetrievalOperation()
    operation.cache = false
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      
      XCTAssertTrue(success)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
    XCTAssertNotNil(operation.convertedObject)
    if let convertedObject = operation.convertedObject as? [String : Int] {
      XCTAssertEqual(convertedObject["key"], 1)
    } else {
      XCTAssert(false, "Dictionary expected")
    }
  }
  
  func testOperationErrorWithoutCache() {
    stubError()
    let operation = CachedNetworkDataRetrievalOperation()
    operation.cache = false
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      XCTAssertFalse(success)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
  }
  
  func testOperationErrorWithCache() {
    stubError()
    let operation = CachedNetworkDataRetrievalOperation()
    operation.cache = true
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      XCTAssertFalse(success)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
  }
  
  func testOperationWithCache() {
    stubMock()
    let operation = CachedNetworkDataRetrievalOperation()
    operation.cache = true
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
    XCTAssertNotNil(operation.convertedObject)
    
    
    if let convertedObject = operation.convertedObject as? [String : Int] {
      XCTAssertEqual(convertedObject["key"], 1)
    } else {
      XCTAssert(false, "Dictionary expected")
    }
    
    OHHTTPStubs.removeAllStubs()
    stubError()
    
    let nonCachedOperation = CachedNetworkDataRetrievalOperation()
    nonCachedOperation.cache = false
    let exp2 = expectation(description: "Operation expectation")
    manager.addOperations([nonCachedOperation]) { (success, results, errors) in
      XCTAssertFalse(success)
      exp2.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
    XCTAssertNil(nonCachedOperation.convertedObject)
    
    
    let cachedOperation = CachedNetworkDataRetrievalOperation()
    cachedOperation.cache = true
    let exp3 = expectation(description: "Operation expectation")
    manager.addOperations([cachedOperation]) { (success, results, errors) in
      XCTAssertTrue(success)
      exp3.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
    
    if let convertedObject = cachedOperation.convertedObject as? [String : Int] {
      XCTAssertEqual(convertedObject["key"], 1)
    } else {
      XCTAssert(false, "Dictionary expected")
    }
  }
  
}
