//
//  NumberConvertable.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 6/25/17.
//  Copyright © 2017 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

public protocol NumberConvertable {
  func toNumber() -> NSNumber
}

extension Int: NumberConvertable {
  public func toNumber() -> NSNumber {
    return NSNumber(value: self)
  }
}

extension Double: NumberConvertable {
  public func toNumber() -> NSNumber {
    return NSNumber(value: self)
  }
}
extension Bool: NumberConvertable {
  public func toNumber() -> NSNumber {
    return NSNumber(value: self)
  }
}

extension String: NumberConvertable {
  public func toNumber() -> NSNumber {
    if let double = Double(self) {
      return double.toNumber()
    }
    if let bool = Bool(self) {
      return bool.toNumber()
    }
    return NSNumber(booleanLiteral: false)
  }
}

