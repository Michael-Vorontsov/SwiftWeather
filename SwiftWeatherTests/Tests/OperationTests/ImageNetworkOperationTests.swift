
//
//  ImageNetworkOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 12/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import DataRetrievalKit
import OHHTTPStubs
@testable import SwiftWeather

class ImageNetworkOperationTests: XCTestCase {
  
  var manager:DataRetrievalOperationManager! = nil
  
  override func setUp() {
    super.setUp()
    
    if nil == manager {
      manager = DataRetrievalOperationManager(remote:"http://stubbed_request.com")
      manager.accessKey = "some_key"
    }
    
  }
  
  override func tearDown() {
    OHHTTPStubs.removeAllStubs()
    super.tearDown()
  }
  
  fileprivate func stubMock() {
    let bundle = Bundle(for: ImageNetworkOperationTests.self)
    stub(condition: isHost("stubbed_request.com")) { _ in
      let imageURL = bundle.url(forResource: "test", withExtension: "jpeg")
      return OHHTTPStubsResponse(fileURL: imageURL!, statusCode: 200, headers: nil)
    }
  }
  
  fileprivate func stubError() {
    stub(condition: isHost("wrong_stubbed_request.com")) { _ in
      let jsonObject = ["error": 0]
      return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil).requestTime(0.1, responseTime: 0.1)
    }
  }
  
  func testImageOperationShortPath() {
    stubMock()
    stubError()
    let operation = ImageNetworkOperation(imagePath: "/image")
    operation.cache = false
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      XCTAssertTrue(success)
      XCTAssertEqual(results.count, 1)
      let fetchedImage = results.first as? UIImage
      XCTAssertNotNil(fetchedImage)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
  }
  
  func testImageOperationWithFullName() {
    stubMock()
    stubError()
    let operation = ImageNetworkOperation(imagePath: "http://wrong_stubbed_request.com/image")
    operation.cache = false
    let exp = expectation(description: "Operation expectation")
    manager.addOperations([operation]) { (success, results, errors) in
      XCTAssertFalse(success)
      exp.fulfill()
    }
    waitForExpectations(timeout: 60.0, handler: nil)
  }
 
}
