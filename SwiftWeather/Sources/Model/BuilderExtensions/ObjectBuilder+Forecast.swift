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
    weather : "weather",
    date : "date",
    pressure : "pressure",
    iconURL : "weatherIconUrl",
    maxTemperature : "maxtempC",
    minTemperature: "mintempC",
    hourly : "hourly"
  )
)

/**
 Extension for building Forecast object. As no forecast objects builds without region, so it's region dependent operation
 */
extension ObjectBuilder {
  
  func buildForecast(_ forecastInfo:[String : AnyObject], region:Region) throws -> DailyForecast {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard
      let context = region.managedObjectContext,
      let dateString = forecastInfo[Consts.responseKeys.date] as? String,
      let date = dateFormatter.date(from: dateString) else {
        throw BuilderErrors.wrongData(dataInfo: forecastInfo)
    }
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: DailyForecast.entityName)
    request.predicate = NSPredicate(format: "region == %@ AND date == %@", region, date as CVarArg)
    let validForecasts = try? context.fetch(request)
    
    guard validForecasts?.count < 2,
      let forecast = (validForecasts?.first as? DailyForecast) ?? DailyForecast(managedContext: context)
      else {
        throw BuilderErrors.coreDataError
    }
    forecast.date = date
    forecast.region = region
    forecast.maxTemp = (forecastInfo[Consts.responseKeys.maxTemperature] as? String ?? "").toNumber()
    forecast.minTemp = (forecastInfo[Consts.responseKeys.minTemperature] as? String ?? "").toNumber()
    
    return forecast
  }
}
