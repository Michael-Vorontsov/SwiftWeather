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
  case unknown = 0
  case n
  case nnw
  case nw
  case wnw
  case w
  case wsw
  case sw
  case ssw
  case s
  case sse
  case se
  case ese
  case e
  case ene
  case ne
  case nne
  
  /**
   Angle from north direction counter clockwise
  */
  var angleRawValue:Double? {
    guard  self != .unknown else {
      return nil
    }
    let sector = rawValue - 1
    let sectoreAngle = M_PI / 16.0
    return Double(sector) * sectoreAngle
  }
  
  init(rawString:String?) {
    let rawString = rawString ?? ""
    switch rawString {
    case "N": self = .n
    case "NNW": self = .nnw
    case "NW": self = .nw
    case "WNW": self = .wnw
    case "W": self = .w
    case "WSW": self = .wsw
    case "SW": self = .sw
    case "SSW": self = .ssw
    case "S": self =  .s
    case "SSE": self = .sse
    case "SE": self = .se
    case "ESE": self = .ese
    case "E": self = .e
    case "ENE": self = .ene
    case "NE": self = .ne
    case "NNE": self = .nne

    default: self = .unknown
    }
  }
  
};

@objc(WeatherCondition)
class WeatherCondition: NSManagedObject, NamedManagedObject {
  
  var windDir:WindDirection {
    guard let windDirection = windDirection else {
      return WindDirection.unknown
    }
    return WindDirection(rawValue:windDirection.intValue) ?? WindDirection.unknown
    
  }
  
  // Insert code here to add functionality to your managed object subclass
  
}
