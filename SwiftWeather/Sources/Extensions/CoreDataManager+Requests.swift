//
//  CoreDataManager+Requests.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import Foundation
import CoreData
import DataRetrievalKit

extension CoreDataManager {
  
  func requestWithRegionName(name:String) -> NSFetchRequest {
    return self.managedObjectModel.fetchRequestFromTemplateWithName("CityByName", substitutionVariables: ["NAME" : name])!
  }
  
  func requestCurrentRegion() -> NSFetchRequest {
    return self.managedObjectModel.fetchRequestTemplateForName("CurrentRegion")!
  }
  
}
