//
//  CurrentLocationOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 08/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import DataRetrievalKit
import CoreLocation

private let timeout =  60.0

/** 
 Operation exctacting current Region with current location
 */
class CurrentLocationOperation: DataRetrievalOperation, CLLocationManagerDelegate, ObjectBuildeOperationProtocol {
  
  var objectBuilder: ObjectBuilder!
  
  var locationManager: CLLocationManager!
  
  var geocoder: CLGeocoder!
  
  var location:CLLocation? = nil
  
  var dataReceived = false
  
  override func prepareForRetrieval() {
    guard true == CLLocationManager.locationServicesEnabled() else {
      breakWithErrorCode(.InvalidParameters, userInfo: nil)
      return
    }
    
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    
    locationManager.requestWhenInUseAuthorization()

    super.prepareForRetrieval()
  }
  
  override func retriveData() {
    
    // First - find current geo location (coordinates)
    super.retriveData()
    self.locationManager.startUpdatingLocation()
    let syncDate = NSDate()
    
    // Can't use semaphore without blocking delegation thread, so use wait loop.
    while false == cancelled && false == dataReceived && timeout > -syncDate.timeIntervalSinceNow {
      NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1))
    }
    
    guard false == cancelled else {
      return
    }
    
    guard true == dataReceived, let location = location else {
      breakWithErrorCode(.NoData)
      return
    }
    
    // Second - revers geocode location to placemark
    geocoder = CLGeocoder()
    let semaphore = dispatch_semaphore_create(0)
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      self.convertedObject = placemarks
      dispatch_semaphore_signal(semaphore)
    }
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC))))
    
  }
  
  //Third: Extract description from placemark
  override func parseData() {
    guard let convertedObject = convertedObject as? [CLPlacemark],
      let placemark = convertedObject.first,
      let builder = objectBuilder else {
        breakWithErrorCode(.InvalidData)
        return
    }
    results = try? builder.buildCurrentRegion(placemark)
  }

  override func cancel() {
    super.cancel()
    locationManager?.stopUpdatingLocation()
    geocoder?.cancelGeocode()
  }
  
}

// MARK: CLLocationManagerDelegate
extension CurrentLocationOperation {
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopUpdatingLocation()
    location = locations.first
    dataReceived = true
    
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    dataReceived = true
    breakWithError(error)
  }
  
}
