//
//  DataRetrievalOperationManager.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 01/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// TODO: Remove hardcoded constants to app delegate
private let Consts = (
  
  defalutBackend : "http://google.com",
  accessKeyParam : "key"
)

public protocol DataRequestor:NSObjectProtocol {
  var dataOperationManager:DataRetrievalOperationManager! {get set}
}

public typealias DataRetrivalCompetionBlock = (_ success: Bool, _ results: [AnyObject], _ errors: [Error]?) -> Void

/**
 Class responsible for retriving data from remote servever.
 
 For each data type specific operation should be created.
 */
open class DataRetrievalOperationManager: NSObject {
  
  open let endPoint:String
  
  open var accessKey:String? = nil
  
  public init(remote:String, accessKey:String? = nil){
    endPoint = remote
    self.accessKey = accessKey
    super.init()
  }
  
  open lazy var session:URLSession = {
    return URLSession.shared
  }()
  
  public override convenience init() {
    self.init(remote:Consts.defalutBackend)
  }
  
  open var coreDataManager:CoreDataManager? = nil
  
  open var objectBuilder:ObjectBuilder? = nil
  
  /**
   Shared instance of Data Retrieval Operation Manager be accessible in different part of application
   */
  open static let sharedManager = DataRetrievalOperationManager()
  
  /**
   Operation queue
   */
  fileprivate lazy var operationQueue: OperationQueue = {
    return OperationQueue()
  }()
  
  var operations:[Operation] {
    return operationQueue.operations
  }
  
  open var suspended:Bool {
    set {
      operationQueue.isSuspended = newValue
    }
    get {
      return operationQueue.isSuspended
    }
  }
  
  
  //  public private(set) lazy var operations:[NSOperation] = {
  //    return [NSOperation]()
  //  }()
  
  /**
   Helpers function for creating completion block operation for specififc operations
   */
  fileprivate func completionBlockOperationForOperations(_ operations:[Operation],
                                                     completionBLock: DataRetrivalCompetionBlock?) -> Operation {
    
    let completionOperation = BlockOperation {() -> Void in
      var success = true
      var errors:[Error]? = nil
      var results:[AnyObject] = []
      
      for operation in operations {
        if  true != operation.isFinished || true == operation.isCancelled {
          success = false
        }
        if let operation = operation as? DataRetrievalOperationProtocol {
          
          if operation.status != .completed {
            if let opError = operation.error {
              if nil == errors {
                errors = [NSError]()
              }
              errors?.append(opError)
            }
            success = false
          }
          if operation.results?.count > 0 {
            results.append(contentsOf: operation.results!)
          }
        }
      }
      
      if let completionBLock = completionBLock {
        OperationQueue.main.addOperation({ () -> Void in
          for operation in operations {
            print("Completion block for: \(operation.name ?? "-")")
          }
          completionBLock(success, results, errors)
        })
      }
    }
    return completionOperation
  }
  
  /**
   Configure operation, add auth headers, endpoints, sesions etc.
   */
  open func prepareOperation(_ operation:Operation) {
    
    //Setup endpoints for all operations
    if let operation = operation as? NetworkDataRetrievalOperationProtocol, nil == operation.requestEndPoint {
      operation.requestEndPoint = self.endPoint
      operation.session = session
    }
    
    if let operation = operation as? ManagedObjectRetrievalOperationProtocol, nil == operation.dataManager {
      operation.dataManager = self.coreDataManager
    }
    
    if let operation = operation as? AccessKeyOperationProtocol, let accessKey = accessKey,  nil == operation.requestParameters[Consts.accessKeyParam] {
      operation.requestParameters[Consts.accessKeyParam] = accessKey as AnyObject
    }
    
    if let operation = operation as? ObjectBuildeOperationProtocol, nil == operation.objectBuilder{
      operation.objectBuilder = self.objectBuilder
    }
    
  }
  
  /**
   Add operations to Queue with completion block.
   Operation should be just created and not executed in any other queue.
   If equal operation already in queue -> then switch all dependecies including completion block to queued one,
   and mark operation as Duplicate
   */
  open func addOperations(
    _ operations: [Operation],
    completionBLock:DataRetrivalCompetionBlock? = nil
  ) -> Void {
    
    DispatchQueue.global(qos: .default).sync { [unowned self] in
      let completionOperation = self.completionBlockOperationForOperations(operations, completionBLock: completionBLock)
      var operationToAdd = [Operation]()
      operationToAdd.append(completionOperation)
      let queuedOperations = self.operations as NSArray
      
      for operation in operations {
        // Attach comppletion operation
        completionOperation.addDependency(operation)
        
        // Skip is not in Created state
        if let operation = operation as? DataRetrievalOperationProtocol, operation.status != .created {
          continue
        }
        
        operationToAdd.append(operation)
        
        //TODO: Complete
        let indexOfSameOperation = queuedOperations.index(of: operation)
        
        // Is similar operation already in queue
        if indexOfSameOperation != NSNotFound, let sameOperation = queuedOperations[indexOfSameOperation] as? Operation {
          if let operation = operation as? DataRetrievalOperationProtocol {
            operation.status = .duplicate
          }
          operation.addDependency(sameOperation)
        } else {
          self.prepareOperation(operation)
          if let operation = operation as? DataRetrievalOperationProtocol {
            operation.status = .queued
          }
        }
        
      }
      self.operationQueue.addOperations(operationToAdd, waitUntilFinished: false)
    }
  }
  
}

