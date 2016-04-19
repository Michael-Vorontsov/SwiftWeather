
//
//  ObjectBuilder+WeatherCondition.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import DataRetrievalKit

private let Consts = (
  responseKeys : (
    currentCondition : "current_condition",
    temperature : "temp_C",
    pressure : "pressure",
    humidity : "humidity",
    windDirection : "winddir16Point",
    windSpeed : "windspeedKmph",
    iconURL : "weatherIconUrl",
    description : "weatherDesc",
    value : "value"
  )
)
/**
 Extension for building Forecast object. As no forecast objects builds without region, so it's region dependent operation
 */
extension ObjectBuilder {
  
  func buildWeatherCondition(forecastInfo:[String : AnyObject], region:Region) throws -> WeatherCondition {
    
    guard let context = region.managedObjectContext else {
      throw BuilderErrors.CoreDataError
    }
    
    let condition = (region.currectCondition ?? WeatherCondition(context: context))
    
    guard let currentCondition = condition else {
      throw BuilderErrors.CoreDataError
    }
    
    currentCondition.region = region
    
    guard
      let temp = forecastInfo[Consts.temperature] as? String,
      let pressure = forecastInfo[Consts.pressure] as? String,
      let humidity = forecastInfo[Consts.humidity] as? String,
      let windSpeed = forecastInfo[Consts.windSpeed] as? String,
      let windDirection = forecastInfo[Consts.windDirection] as? String else {
        throw BuilderErrors.IncompleteData
    }
    
    if
      let weatherDescriptionInfoArray = forecastInfo[Consts.description] as? [AnyObject],
      let weatherDescriptionInfo = weatherDescriptionInfoArray.last as? [String : AnyObject],
      let weatherDescription = weatherDescriptionInfo[Consts.value] as? String {
      currentCondition.weatherDescription = weatherDescription
    } else {
      currentCondition.weatherDescription = "-"
    }
    
    currentCondition.temperature = Int(temp )
    currentCondition.pressure = Int(pressure)
    currentCondition.windSpeed = Int(windSpeed)
    currentCondition.humidity = Int(humidity
    )
    currentCondition.windDirection = WindDirection(rawString: windDirection).rawValue
    
    if
      let iconInfoArray = forecastInfo[Consts.iconURL] as? [AnyObject],
      let iconInfo = iconInfoArray.first as? [String : AnyObject],
      let iconPath = iconInfo[Consts.value] as? String {
        currentCondition.weatherIconPath =  iconPath
    }
    
    return currentCondition
  }
}
