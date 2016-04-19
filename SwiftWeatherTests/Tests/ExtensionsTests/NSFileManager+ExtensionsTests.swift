//
//  NSFileManager+ExtensionsTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
@testable import SwiftWeather

class NSFileManager_ExtensionsTests: XCTestCase {
  
  func testAppDirectory() {
    let appDirs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    XCTAssertTrue(appDirs.contains(NSFileManager.applicationDocumentsDirectory))
  }
  
  func testCachesDirectory() {
    let appDirs = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
    XCTAssertTrue(appDirs.contains(NSFileManager.applicationCachesDirectory))
  }
  
  
}
