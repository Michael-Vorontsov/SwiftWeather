//
//  SampleOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 6/25/17.
//  Copyright © 2017 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import DataRetrievalKit

class SampleMSGObject:NSObject{
  var userID:Int = 0
  var sid: Int = 0
  var title: String?
  var body: String?
}

class SampleNetworkSyncOperation: NetworkDataRetrievalOperation {
  
  override func prepareForRetrieval() throws {
    requestPath = "posts"
    try super.prepareForRetrieval()
  }
  
  override func parseData() throws {
    try super.parseData()
    var objects:[AnyObject] = []
    let dataInfo = convertedObject
    guard  false == isCancelled else  { return }
    
    let infoArray  = dataInfo as! [[String : AnyObject]]
    for objectInfo:[String : AnyObject] in infoArray {
      guard let userID = objectInfo["userId"] as? Int,
        let sid = objectInfo["id"] as? Int else { continue }
      
      let object = SampleMSGObject()
      
      object.userID = userID
      object.sid = sid
      object.title = objectInfo["title"] as? String
      object.body = objectInfo["body"] as? String
      
      objects .append(object)
    }
    results =  objects;
  }
}

class SampleAcceessTokenOperation: SampleNetworkSyncOperation, AccessKeyOperationProtocol {}
