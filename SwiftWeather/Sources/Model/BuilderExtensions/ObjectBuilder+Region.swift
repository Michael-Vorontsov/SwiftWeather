//
//  ObjectBuilder+Region.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData
import DataRetrievalKit
import CoreLocation

enum RegionBuilderErrors:ErrorType {
  case NoContextAvailable
  case CoreDataError
  case RemoteError(errorInfo:AnyObject)
  case WrongData(dataInfo:[String : AnyObject])
  case IncompleteData
}

private let Consts = (
  path : "/weather.ashx",
  range : 5,
  dataFormat : "json",
  requestKeys : (
    querry : "q",
    format : "format",
    days : "num_of_days"
  ),
  responseKeys : (
    data : "data",
    condition : "current_condition",
    weather : "weather",
    date : "date",
    error : "error",
    request : "request",
    querry : "query",
    hourly : "hourly"
  )
)

/**
 Extension for building Region object. Use
 */
extension ObjectBuilder {
  /**
   Wrap region building into data context.
   */
  func buildRegion(forecastInfo:[String : AnyObject], updateId:NSManagedObjectID? = nil) throws -> [AnyObject] {
    guard let dataManager = coreDataManager else {
      throw RegionBuilderErrors.NoContextAvailable
    }
    let dataContext = dataManager.dataContext
    
    if let errorInfo = forecastInfo[Consts.responseKeys.error] {
      throw RegionBuilderErrors.RemoteError(errorInfo: errorInfo)
    }
    
    guard let info = forecastInfo[Consts.responseKeys.data] as? [String : AnyObject] else {
      throw RegionBuilderErrors.WrongData(dataInfo: forecastInfo)
    }
    
    var parsingError:ErrorType? = nil
    var results:[AnyObject] = [AnyObject]()
    
    dataContext.performBlockAndWait{
      do {
        let region = try self.buildRegion(info, updateId: updateId, context: dataContext)
        results.append(region.objectID)
      } catch {
        parsingError = error
      }
    }
    dataContext.save(recursive: true)
    
    if let parsingError = parsingError {
      throw parsingError
    }
    
    return results
  }
  
  /**
   Actually build region object in specific context
   */
  func buildRegion(forecastInfo:[String : AnyObject], updateId:NSManagedObjectID? = nil , context:NSManagedObjectContext ) throws -> Region{
    
        guard
          let reqestArray = forecastInfo[Consts.responseKeys.request] as? [AnyObject],
          let requestInfo = reqestArray.last as? [String : AnyObject],
          let regionName = requestInfo[Consts.responseKeys.querry] as? String,
          let conditionInfo = (forecastInfo[Consts.responseKeys.condition] as? [[String : AnyObject]])?.last,
          let forecastsInfo = forecastInfo[Consts.responseKeys.weather] as? [[String : AnyObject]]
          else {
            throw RegionBuilderErrors.WrongData(dataInfo: forecastInfo)
        }
    
    guard let coreDataManager = coreDataManager else {
      throw RegionBuilderErrors.NoContextAvailable
    }
    
    
    let regionRequest = coreDataManager.requestWithRegionName(regionName)
    let regions = try? context.executeFetchRequest(regionRequest)
    
    var regionToUpdate:Region? = nil
    if let updateId = updateId, let regionFromId = context.objectWithID(updateId) as? Region {
      regionToUpdate = regionFromId
    }

    guard let region = regionToUpdate ?? (regions?.last as? Region) ?? Region(context:context) else {
      throw RegionBuilderErrors.CoreDataError
    }
    region.name = regionName
    
    do {
      region.currectCondition =  try buildWeatherCondition(conditionInfo, region: region)
      let forecastToRemove = region.forecasts?.mutableCopy() as? NSMutableSet
      for forecastInfo in forecastsInfo {
        let forecast = try buildForecast(forecastInfo, region: region)
        forecastToRemove?.removeObject(forecast)
      }
      
    } catch {
      throw error
    }
    return region
  }
  
  /**
   Update current region
   */
  
  func buildCurrentRegion(placemark:CLPlacemark) throws -> [AnyObject] {
//    guard let coreDataManager = coreDataManager else {
//      throw RegionBuilderErrors.NoContextAvailable
//    }
    let dataContext = coreDataManager.dataContext
    var regions = [AnyObject]()
    
    dataContext.performBlockAndWait {
//      let request = self.coreDataManager.requestCurrentRegion()
      let request = NSFetchRequest(entityName: Region.entityName)
      request.predicate = NSPredicate(format: "isCurrent == %@", true)
      let allCurrentRegions = try? dataContext.executeFetchRequest(request)
      var region = (allCurrentRegions?.last) as? Region
      region = region ?? Region(context: dataContext)
      
      
      region!.isCurrent = true
      region!.name = "\(placemark.locality!)"
      regions.append(region!.objectID)
      
      
    }
    
    return regions
  }
  
}
