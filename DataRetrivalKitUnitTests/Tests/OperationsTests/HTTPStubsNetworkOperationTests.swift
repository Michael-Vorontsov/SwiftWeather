//
//  HTTPStubsNetworkOperationTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 07/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import DataRetrievalKit

class HTTPStubsNetworkOperationTests: XCTestCase {
  
  weak var savedStub: OHHTTPStubsDescriptor?
  var manager:DataRetrievalOperationManager!
  
  fileprivate func stubMock() {
    
    savedStub = stub(condition: isHost("stubbed_request.com")) { _ in
      
      let jsonObject = [
        [
          "userId": 1,
          "id": 1,
          "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
          "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
        ],
        [
          "userId": 1,
          "id": 2,
          "title": "qui est esse",
          "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
        ]
      ]
      return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil).requestTime(1.0, responseTime: 3.0)
    }
  }
  
  func stubError(_ code:Int) {
    savedStub = stub(condition: isHost("stubbed_request.com")) { _ in
      
      let jsonObject = [
        "error": "Stub for error",
        "errorDescription": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        ]
      
      return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: Int32(code), headers: nil).requestTime(1.0, responseTime: 3.0)
    }
  }
  
  override func setUp() {
    super.setUp()
    
    if nil == manager {
      manager = DataRetrievalOperationManager(remote:"http://stubbed_request.com")
      manager.accessKey = "some_key"
    }
    manager.session = URLSession(configuration: URLSessionConfiguration.default)
  }
  
  override func tearDown() {
    super.tearDown()
    OHHTTPStubs.removeAllStubs()
    OHHTTPStubs.setEnabled(false)
  }
  
  func testSimpleOperation() {
    
    stubMock()
    
    let operation = SampleNetworkSyncOperation()
    XCTAssertNotNil(operation)
    XCTAssertNil(operation.requestPath)
    XCTAssertNil(operation.requestEndPoint)
    XCTAssertEqual(operation.stage, OperationStage.awaiting)
    XCTAssertEqual(operation.status, OperationStatus.created)
    XCTAssertNil(operation.request)
    
    var completed:Bool = false
    
    let expct:XCTestExpectation = self.expectation(description: "Awaiting request")
    
    manager.addOperations([operation]) { (success, results, errors) -> Void in
      XCTAssertTrue(success)
      XCTAssertNil(errors)
      XCTAssertFalse(completed)
      XCTAssertGreaterThan(results.count, 1)
      
      if results.count > 1 {
        let sampleObject1:SampleMSGObject = results[0] as! SampleMSGObject
        let sampleObject2:SampleMSGObject = results[1] as! SampleMSGObject
        XCTAssertNotNil(sampleObject1)
        XCTAssertNotNil(sampleObject2)
        XCTAssertNotEqual(sampleObject1, sampleObject2)
        XCTAssertEqual(sampleObject1.userID, sampleObject2.userID)
        XCTAssertNotEqual(sampleObject1.sid, sampleObject2.sid)
        XCTAssertNotEqual(sampleObject1.title, sampleObject2.title)
        XCTAssertNotEqual(sampleObject1.body, sampleObject2.body)
      }
      
      XCTAssertEqual(self.manager.operations.count, 0)
      
      XCTAssertEqual(operation.stage, OperationStage.completed)
      completed = true
      expct.fulfill()
    }
    
    XCTAssertEqual(manager.operations.count, 2)
    
    XCTAssertFalse(completed)
    
    self.waitForExpectations(timeout: 30.0, handler: nil)
    
    XCTAssertNotNil(operation.requestPath)
    XCTAssertEqual(operation.requestPath, "posts")
    XCTAssertEqual(operation.requestEndPoint, "http://stubbed_request.com")
    XCTAssertNotNil(operation.request)
    XCTAssertEqual(operation.request?.url?.absoluteString, "http://stubbed_request.com/posts")
    XCTAssertTrue(completed)
  }
  
  func testAccessToken() {
    stubMock()
    
    let operation = SampleAcceessTokenOperation()
    XCTAssertNotNil(operation)
    XCTAssertNotNil(operation.requestParameters)
    XCTAssertNil(operation.requestParameters["key"])
    let expct:XCTestExpectation = self.expectation(description: "Awaiting request")
    
    manager.addOperations([operation]) { (success, results, errors) -> Void in
      expct.fulfill()
    }
    
    XCTAssertNotNil(operation.requestParameters["key"])
    XCTAssertEqual(operation.requestParameters["key"] as? String, "some_key")
    waitForExpectations(timeout: 30.0, handler: nil)
  }
  
  func testError() {
    stubError(400)
    
    let operation = SampleNetworkSyncOperation()
    var completed:Bool = false
    let expct:XCTestExpectation = self.expectation(description: "Awaiting request")
    manager.addOperations([operation]) { (success, results, errors) -> Void in
      XCTAssertFalse(success)
      XCTAssertNotNil(errors)
      XCTAssertNotNil(results)
      XCTAssertEqual(results.count, 0)
      
      if let errors = errors,
        let error = errors.first as? DataRetrievalOperationError {
        
        switch error {
        case .serverResponse(let errorCode, let errorResponse, _) :
          XCTAssertEqual(errorCode, 400)
          XCTAssertNotNil(errorResponse)
        default:
          XCTAssertTrue(false, "ServerResponse error expected")
        }
      } else {
        XCTAssert(false, "Errors expected")
      }
      
      XCTAssertEqual(self.manager.operations.count, 0)
      
      XCTAssertEqual(operation.stage, OperationStage.requesting)
      XCTAssertEqual(operation.status, OperationStatus.error)
      completed = true
      expct.fulfill()
    }
    
    XCTAssertEqual(manager.operations.count, 2)
    
    XCTAssertFalse(completed)
    
    self.waitForExpectations(timeout: 300.0, handler: nil)
  }
  
}
