//
//  WeatherCondition.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData

enum WindDirection: Int {
  case Unknown = 0
  case N
  case NNW
  case NW
  case WNW
  case W
  case WSW
  case SW
  case SSW
  case S
  case SSE
  case SE
  case ESE
  case E
  case ENE
  case NE
  case NNE
  
  /**
   Angle from north direction counter clockwise
  */
  var angleRawValue:Double? {
    guard  self != .Unknown else {
      return nil
    }
    let sector = rawValue - 1
    let sectoreAngle = M_PI / 16.0
    return Double(sector) * sectoreAngle
  }
  
  init(rawString:String?) {
    let rawString = rawString ?? ""
    switch rawString {
    case "N": self = .N
    case "NNW": self = .NNW
    case "NW": self = .NW
    case "WNW": self = .WNW
    case "W": self = .W
    case "WSW": self = .WSW
    case "SW": self = .SW
    case "SSW": self = .SSW
    case "S": self =  .S
    case "SSE": self = .SSE
    case "SE": self = .SE
    case "ESE": self = .ESE
    case "E": self = .E
    case "ENE": self = .ENE
    case "NE": self = .NE
    case "NNE": self = .NNE

    default: self = .Unknown
    }
  }
  
};

@objc(WeatherCondition)
class WeatherCondition: NSManagedObject, NamedManagedObject {
  
  var windDir:WindDirection {
    guard let windDirection = windDirection else {
      return WindDirection.Unknown
    }
    return WindDirection(rawValue:windDirection.integerValue) ?? WindDirection.Unknown
    
  }
  
  // Insert code here to add functionality to your managed object subclass
  
}
