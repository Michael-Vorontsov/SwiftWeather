//
//  DataRetrievalOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

/**
 Most basic operation. Used as abstract class for all Data Retrieval operations.
 */
open class DataRetrievalOperation: Operation, DataRetrievalOperationProtocol {
  
  open var force:Bool = false
  
  open var status: OperationStatus = .created
  open var stage: OperationStage = .awaiting
  open var convertedObject: AnyObject?
  open var data: Data? = nil
  open var error:Error? = nil
  open var results:[AnyObject]? = nil
  
  open func prepareForRetrieval() throws {}
  
  open func retriveData() throws {}
  
  open func convertData() throws {}
  
  open func parseData() throws {}
  
  open func breakWithNSError(_ error: NSError) {
    breakWithError(DataRetrievalOperationError.wrappedNSError(error: error))
  }

  open func breakWithError(_ error: Error) {
    guard stage != .completed && status != .completed else {
      return
    }
    self.error = error
    status = .error
    self.cancel()
  }
  
  override open func main(){
    
    guard false == isCancelled else { return }
    
    // If not forced and any parent operation is canceled - then cancel
    if false == force {
      
      // Duplicate operations should have original operation as last dependant operation
      // so it should extract stage, error, results, etc. from it and return
      if .duplicate ==  self.status, let original = dependencies.last as? DataRetrievalOperation {
        results = original.results
        stage = original.stage
        status = original.status
        error = original.error
        if original.isCancelled {
          cancel()
        }
        return
      }
      
      for operation in dependencies {
        if true == operation.isCancelled || false == operation.isFinished{
          cancel()
          return;
        }
        if let operation = operation as? DataRetrievalOperation, operation.status  != .completed && operation.stage  != .completed {
          cancel()
          return;
        }
      }
    }
    
    do {
      guard false == isCancelled && status == .queued && stage == .awaiting else {return}
      status = .executing
      stage = .preparing
      try prepareForRetrieval()
      guard false == isCancelled else { return }
      stage = .requesting
      try retriveData()
      guard false == isCancelled else { return }
      stage = .converting
      try convertData()
      guard false == isCancelled else { return }
      stage = .parsing
      try parseData()
      
      if .executing == status {
        status = .completed
        stage = .completed
      }
    } catch {
      status = .error
      self.error = error
    }
  }
  
  override open func cancel() {
    if  .error != status {
      status = .cancelled
    }
    super.cancel()
  }
  
  // Compare operations by name hash
  override open var hash: Int {
    
    
    
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
  
  override open func isEqual(_ object: Any?) -> Bool {
    if let object = object {
      return self.hash == (object as AnyObject).hash
    }
    return false
  }
  
}

extension NSObjectProtocol where Self:DataRetrievalOperation {
  
  var operationFullName: String {
    return NSStringFromClass(Self.self) + "." + (name ?? "")
  }
  
}

