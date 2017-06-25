//
//  NSFileManager+Extensions.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation

extension FileManager {
  /**
   Return application document directory
   */
  @nonobjc static let applicationDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls.last!
  }()

  @nonobjc static let applicationCachesDirectory: URL = {
    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return urls.last!
  }()

}
