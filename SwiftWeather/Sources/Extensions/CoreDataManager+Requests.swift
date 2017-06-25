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
  
  func requestWithRegionName(_ name:String) -> NSFetchRequest<NSFetchRequestResult> {
    return self.managedObjectModel.fetchRequestFromTemplate(withName: "CityByName", substitutionVariables: ["NAME" : name])!
  }
  
  func requestCurrentRegion() -> NSFetchRequest<NSFetchRequestResult> {
    return self.managedObjectModel.fetchRequestTemplate(forName: "CurrentRegion")!
  }
  
}
