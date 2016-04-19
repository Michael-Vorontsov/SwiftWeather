//
//  DataRetrievalOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

private let consts = (
  errorDomain : "operation"
)
/**
 Most basic operation. Used as abstract class for all Data Retrieval operations.
 */
public class DataRetrievalOperation: NSOperation, DataRetrievalOperationProtocol {
  
  public var force:Bool = false
  
  public var status: OperationStatus = .Created
  public var stage: OperationStage = .Awaiting
  public var convertedObject: AnyObject?
  public var data: NSData? = nil
  public var error:NSError? = nil
  public var results:[AnyObject]? = nil
  
  public func prepareForRetrieval() {}
  
  public func retriveData() {}
  
  public func convertData() {}
  
  public func parseData() {}
  
  public func breakWithError(error: NSError) {
    guard stage != .Completed && status != .Completed else {
      return
    }
    self.error = error
    status = .Error
    self.cancel()
  }
  
  public func breakWithErrorCode(code: RetrievalOperationErrorCodes = RetrievalOperationErrorCodes.Unknown, userInfo:[String : AnyObject]? = nil) {
    let error = NSError(domain: consts, code: code.rawValue, userInfo: userInfo)
    breakWithError(error)
  }
  
  override public func main(){
    
    guard false == cancelled else { return }
    
    // If not forced and any parent operation is canceled - then cancel
    if false == force {
      
      // Duplicate operations should have original operation as last dependant operation
      // so it should extract stage, error, results, etc. from it and return
      if .Duplicate ==  self.status, let original = dependencies.last as? DataRetrievalOperation {
        results = original.results
        stage = original.stage
        status = original.status
        error = original.error
        if original.cancelled {
          cancel()
        }
        return
      }
      
      for operation in dependencies {
        if true == operation.cancelled || false == operation.finished{
          cancel()
          return;
        }
        if let operation = operation as? DataRetrievalOperation where operation.status  != .Completed && operation.stage  != .Completed {
          cancel()
          return;
        }
      }
    }
    
    guard false == cancelled && status == .Queued && stage == .Awaiting else {return}
    status = .Executing
    stage = .Preparing
    prepareForRetrieval()
    guard false == cancelled else { return }
    stage = .Requesting
    retriveData()
    guard false == cancelled else { return }
    stage = .Converting
    convertData()
    guard false == cancelled else { return }
    stage = .Parsing
    parseData()
    
    if .Executing == status {
      status = .Completed
      stage = .Completed
    }
  }
  
  override public func cancel() {
    if  .Error != status {
      status = .Cancelled
    }
    super.cancel()
  }
  
  // Compare operations by name hash
  override public var hash: Int {
    
    
    
//// Unnamed operations is different
//    guard let name = name else {
//      return super.hash
//    }
//    return name.hash

//// Operations depends on their type: with same name but different type is different
    let mirror = Mirror(reflecting: self)
    guard let objectType = mirror.subjectType as? AnyClass else {
      return super.hash
    }
    let className = NSStringFromClass(objectType)
    let hash = (className + "." + (name ?? "")).hash
    return hash
}
  
  override public func isEqual(object: AnyObject?) -> Bool {
    if let object = object {
      return self.hash == object.hash
    }
    return false
  }
  
}

extension NSObjectProtocol where Self:DataRetrievalOperation {
  
  var operationFullName: String {
    return NSStringFromClass(Self) + "." + (name ?? "")
  }
  
}

