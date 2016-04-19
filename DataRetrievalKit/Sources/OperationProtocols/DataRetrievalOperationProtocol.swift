//
//  DataRetrievalOperationProtocol.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 08/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

public enum OperationStage:Int {
  case Awaiting
  case Preparing
  case Requesting
  case Converting
  case Parsing
  case Completed
}

public enum OperationStatus:Int {
  case Created
  case Queued
  case Executing
  case Paused
  case Duplicate
  case Cancelled
  case Error
  case Completed
}

/* TODO: Refactor
 Operation codes should be refactored to ErrorType, and use throw 
 instead of cuurent version's breakWithError() + retrun
*/
public enum RetrievalOperationErrorCodes:Int {
  case Unknown
  case InvalidParameters
  case NoData
  case InvalidData
  case InvalidDataFormat
  case ServerError
  case Networking
  case CoreServiceError
  case CoreData
  
  public static let errorInfoKeys = (
    response: "response",
    serverCode: "errorCode"
  )
}
/**
 Public inteface for common data operation.
 Data can be retrived from network, file on disk, internal services (geolcation for ex.), etc
 
 Data operation consist of 5 stages:
 1. Prepare for Retrieval (for ex: generate file name or create request, setup parameters, headers, etc.)
 2. Retrive data (for ex. read file, or request data from remote host)
 3. Convert binary data to more general type: dictionary, array, decode encripted data etc.
 4. Parse converted general type to application internal model objects, update existed objects, process and store them, if needed.
 
 Each specific operations should override necessary steps.
 
 All operations should be executed in DataRetrievalManager.
 Manager can perfrome additional operation cofiguration if needed (for ex. add authorization headers, etc.)
 Operations can depends on each others. If parent operation not succeed (breaked with error, or cancelled), depandant should be cancelled, if not forced.
 Forced operations should be executed anyway, after completion of dependant operation (either with error, or not)
 
 Stauts reflects current operation status,
 Stage relects current operation stage.
 
 Name is essential part of operation. Assuming that unique operation should have unique names,
 and if operations have equal names it means that operations considered to do similar job.
 So if one operation with some name is already scheduled, then all next same named operations actually would not be performed, but takes results (statuses and errors) from that operation.
 If operation has no name that identify of operations tracking by default hash mechanism.
 */

public protocol DataRetrievalOperationProtocol: NSObjectProtocol {
  
  func prepareForRetrieval()
  func retriveData()
  func convertData()
  func parseData()
  
  func breakWithErrorCode(code: RetrievalOperationErrorCodes, userInfo:[String : AnyObject]?)
  
  var error:NSError? {get}
  var force:Bool {get set}
  var status:OperationStatus {get set}
  var stage:OperationStage {get set}
  var data:NSData? {get set}
  var results:[AnyObject]? {get set}
  var convertedObject:AnyObject? {get set}
}


