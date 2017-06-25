//
//  NSFileManager+ExtensionsTests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest
import DataRetrievalKit
@testable import SwiftWeather

class NSFileManager_ExtensionsTests: XCTestCase {
  
  func testAppDirectory() {
    let appDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    XCTAssertTrue(appDirs.contains(FileManager.applicationDocumentsDirectory))
  }
  
  func testCachesDirectory() {
    let appDirs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    XCTAssertTrue(appDirs.contains(FileManager.applicationCachesDirectory))
  }
  
  
}
