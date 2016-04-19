//
//  SwiftWeatherUITests.swift
//  SwiftWeatherUITests
//
//  Created by Mykhailo Vorontsov on 13/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import XCTest

class SwiftWeatherUITests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    XCUIApplication().launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  /**
   Simple UI test to navigate through all application, and test core functionality.
   
   Require network connection and location enabled on device.
   Should work on all location, however testes for Apple and London.
   */
  func testCommonFlow() {
    XCUIDevice.sharedDevice().orientation = .Portrait
    
    let app = XCUIApplication()
    let showmenuButton = app.buttons["ShowMenu"]
    
    showmenuButton.tap()
    let tablesQuery = app.tables
    
    let currentLocationStaticText = tablesQuery.allElementsBoundByIndex[1].cells.allElementsBoundByIndex[0]
    
    currentLocationStaticText.tap()
    
    showmenuButton.tap()
    
    let editButton = tablesQuery.buttons["Edit"]
    editButton.tap()
    
    let addButton = tablesQuery.buttons["Add"]
    addButton.tap()
    tablesQuery.searchFields.containingType(.Button, identifier:"Clear text").element
    
    let searchBar = tablesQuery.searchFields.allElementsBoundByIndex[0]
    searchBar.typeText("Ireland Dublin\n")
    
    let dublinStaticText = tablesQuery.cells.staticTexts["Dublin(Ireland)"]
    
    dublinStaticText.tap()
    showmenuButton.tap()
    dublinStaticText.tap()
    showmenuButton.tap()
    
    currentLocationStaticText.tap()
    showmenuButton.tap()
    
    editButton.tap()
    let deleteDublinButton = tablesQuery.buttons["Delete Dublin(Ireland)"]
    deleteDublinButton.tap()
    let deleteButton = tablesQuery.buttons["Delete"]
    deleteButton.tap()
    addButton.tap()
    searchBar.typeText("Glasgow\n")
    let glasgowStaticText = tablesQuery.cells.staticTexts["Glasgow(United Kingdom)"]
    glasgowStaticText.tap()
    showmenuButton.tap()
    glasgowStaticText.tap()
    showmenuButton.tap()
    editButton.tap()
    let deleteGlasgowButton = tablesQuery.buttons["Delete Glasgow(United Kingdom)"]
    deleteGlasgowButton.tap()
    glasgowStaticText.tap()
    
    let cancelButton = tablesQuery.buttons["Cancel"]
    cancelButton.tap()
    editButton.tap()
    deleteGlasgowButton.tap()
    deleteButton.tap()
    cancelButton.tap()
    currentLocationStaticText.tap()
  }
  
}
