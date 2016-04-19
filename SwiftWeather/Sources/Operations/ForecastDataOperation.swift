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
  
  private(set) var querry:String! = nil
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
    self.name = String(region.objectID)
  }

  init(regionIdentifier:NSManagedObjectID) {
    regionID = regionIdentifier
    super.init()
    self.name = String(regionIdentifier)
  }

  
  override func prepareForRetrieval() {
    
    if let regionID = regionID where nil == querry {
      let context = objectBuilder.coreDataManager.dataContext
      context.performBlockAndWait({
        if let regionToUpdate = context.objectWithID(regionID) as? Region {
          self.querry = regionToUpdate.name
        }
      })
    }
    
    requestPath = Consts.path
    requestParameters[Consts.requestKeys.querry] = querry
    requestParameters[Consts.requestKeys.days] = Consts.range
    requestParameters[Consts.requestKeys.format] = Consts.dataFormat
    
    super.prepareForRetrieval()
  }
  
  override func parseData() {
    guard let objectBuilder = objectBuilder,
      let convertedObject = convertedObject else {
        
        breakWithErrorCode(.InvalidParameters)
        return
    }
    
    guard let dictionaryInfo = convertedObject as? [String : AnyObject] else {
      breakWithErrorCode(.InvalidParameters)
      return
    }
    
    do {
      self.results = try objectBuilder.buildRegion(dictionaryInfo,updateId: regionID)
    } catch {
      breakWithErrorCode(.InvalidData)
    }
  }
  
}
