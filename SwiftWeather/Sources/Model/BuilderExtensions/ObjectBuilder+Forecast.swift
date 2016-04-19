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
  
  func buildForecast(forecastInfo:[String : AnyObject], region:Region) throws -> DailyForecast {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    guard
      let context = region.managedObjectContext,
      let dateString = forecastInfo[Consts.responseKeys.date] as? String,
      let date = dateFormatter.dateFromString(dateString) else {
        throw BuilderErrors.WrongData(dataInfo: forecastInfo)
    }
    
    let request = NSFetchRequest(entityName: DailyForecast.entityName)
    request.predicate = NSPredicate(format: "region == %@ AND date == %@", region, date)
    let validForecasts = try? context.executeFetchRequest(request)
    
    guard validForecasts?.count < 2,
      let forecast = (validForecasts?.first as? DailyForecast) ?? DailyForecast(context: context)
      else {
        throw BuilderErrors.CoreDataError
    }
    forecast.date = date
    forecast.region = region
    forecast.maxTemp = Int(forecastInfo[Consts.responseKeys.maxTemperature] as? String ?? "")
    forecast.minTemp = Int(forecastInfo[Consts.responseKeys.minTemperature] as? String ?? "")
    
    return forecast
  }
}
