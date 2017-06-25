//
//  ForecastDataOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData
import DataRetrievalKit

private let Consts = (
  path : "/weather.ashx",
  range : 5,
  dataFormat : "json",
  requestKeys : (
    querry : "q",
    format : "format",
    days : "num_of_days"
  )
)

/**
 Operation exctacting forecast for specified regions. 
 
 Region can be specified by name, or provided as ManagedObject to update.
 */
class ForecastDataOperation: NetworkDataRetrievalOperation, ObjectBuildeOperationProtocol, AccessKeyOperationProtocol {
  
  var objectBuilder : ObjectBuilder!
  
  fileprivate(set) var querry:String! = nil
  let regionID:NSManagedObjectID?
  
  init(regionName:String) {
    regionID = nil
    super.init()
    querry = regionName
    name = regionName
  }
  
  init(region:Region) {
    regionID = region.objectID
    super.init()
    self.name = String(describing: region.objectID)
  }

  init(regionIdentifier:NSManagedObjectID) {
    regionID = regionIdentifier
    super.init()
    self.name = String(describing: regionIdentifier)
  }

  
  override func prepareForRetrieval() throws {
    
    if let regionID = regionID, nil == querry {
      let context = objectBuilder.coreDataManager.dataContext
      context.performAndWait({
        if let regionToUpdate = context.object(with: regionID) as? Region {
          self.querry = regionToUpdate.name
        }
      })
    }
    
    requestPath = Consts.path
    requestParameters[Consts.requestKeys.querry] = querry as AnyObject
    requestParameters[Consts.requestKeys.days] = Consts.range as AnyObject
    requestParameters[Consts.requestKeys.format] = Consts.dataFormat as AnyObject
    
    try super.prepareForRetrieval()
  }
  
  override func parseData() throws {
    guard let objectBuilder = objectBuilder,
      let convertedObject = convertedObject else {
        throw DataRetrievalOperationError.invalidParameter(parameterName: "convertedObject")
    }
    
    guard let dictionaryInfo = convertedObject as? [String : AnyObject] else {
      throw DataRetrievalOperationError.invalidDataForKey(key: "root", value: nil)
    }
    
    do {
      self.results = try objectBuilder.buildRegion(dictionaryInfo,updateId: regionID)
    } catch {
      throw DataRetrievalOperationError.internalError(error: error)
    }
  }
  
}
