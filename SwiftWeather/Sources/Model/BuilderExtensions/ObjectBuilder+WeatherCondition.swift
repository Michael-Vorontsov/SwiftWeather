
//
//  ObjectBuilder+WeatherCondition.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import DataRetrievalKit

fileprivate let Consts = (
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
  ),
  // In swfti3 forbidden to declare tuple with only one key-value
  placeholder : false
)
/**
 Extension for building Forecast object. As no forecast objects builds without region, so it's region dependent operation
 */
extension ObjectBuilder {
  
  func buildWeatherCondition(_ forecastInfo:[String : AnyObject], region:Region) throws -> WeatherCondition {
    
    guard let context = region.managedObjectContext else {
      throw BuilderErrors.coreDataError
    }
    
    let condition = (region.currectCondition ?? WeatherCondition(managedContext: context))
    
    guard let currentCondition = condition else {
      throw BuilderErrors.coreDataError
    }
    
    currentCondition.region = region
    
    guard
      let temp = forecastInfo[Consts.responseKeys.temperature] as? String,
      let pressure = forecastInfo[Consts.responseKeys.pressure] as? String,
      let humidity = forecastInfo[Consts.responseKeys.humidity] as? String,
      let windSpeed = forecastInfo[Consts.responseKeys.windSpeed] as? String,
      let windDirection = forecastInfo[Consts.responseKeys.windDirection] as? String else {
        throw BuilderErrors.incompleteData
    }
    
    if
      let weatherDescriptionInfoArray = forecastInfo[Consts.responseKeys.description] as? [AnyObject],
      let weatherDescriptionInfo = weatherDescriptionInfoArray.last as? [String : AnyObject],
      let weatherDescription = weatherDescriptionInfo[Consts.responseKeys.value] as? String {
      currentCondition.weatherDescription = weatherDescription
    } else {
      currentCondition.weatherDescription = "-"
    }
    
//    currentCondition.temperature = Int(temp).toNumber()
//    currentCondition.pressure = Int(pressure)
//    currentCondition.windSpeed = Int(windSpeed)
//    currentCondition.humidity = Int(humidity
    
      currentCondition.temperature = temp.toNumber()
      currentCondition.pressure = pressure.toNumber()
      currentCondition.windSpeed = windSpeed.toNumber()
      currentCondition.humidity = humidity.toNumber()

    
    currentCondition.windDirection = WindDirection(rawString: windDirection).rawValue.toNumber()
    
    if
      let iconInfoArray = forecastInfo[Consts.responseKeys.iconURL] as? [AnyObject],
      let iconInfo = iconInfoArray.first as? [String : AnyObject],
      let iconPath = iconInfo[Consts.responseKeys.value] as? String {
        currentCondition.weatherIconPath =  iconPath
    }
    
    return currentCondition
  }
}
