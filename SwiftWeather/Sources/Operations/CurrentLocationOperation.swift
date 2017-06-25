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
  
  var geolocationError:NSError? = nil
  
  override func prepareForRetrieval() throws {
    guard true == CLLocationManager.locationServicesEnabled() else {
      throw DataRetrievalOperationError.invalidParameter(parameterName: "locationServicesEnabled")
    }
    
    DispatchQueue.main.sync {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
    }

    try super.prepareForRetrieval()
  }
  
  override func retriveData() throws {
    
    // First - find current geo location (coordinates)
    try super.retriveData()
    
    self.locationManager.startUpdatingLocation()
    let syncDate = Date()
    
    // Can't use semaphore without blocking delegation thread, so use wait loop.
    while false == isCancelled && false == dataReceived && timeout > -syncDate.timeIntervalSinceNow {
      RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
    }
    
    guard false == isCancelled else {
      return
    }
    
    guard true == dataReceived, let location = location else {
      throw DataRetrievalOperationError.wrongDataFormat(error: nil)
    }
    
    // Second - revers geocode location to placemark
    geocoder = CLGeocoder()
    let semaphore = DispatchSemaphore(value: 0)
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      self.convertedObject = placemarks as AnyObject
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
    if let geolocationError = geolocationError {
      throw DataRetrievalOperationError.wrappedNSError(error: geolocationError)
    }
    
    
  }
  
  //Third: Extract description from placemark
  override func parseData() throws {
    guard let convertedObject = convertedObject as? [CLPlacemark],
      let placemark = convertedObject.first,
      let builder = objectBuilder else {
        throw DataRetrievalOperationError.internalError(error: nil)
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
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopUpdatingLocation()
    location = locations.first
    dataReceived = true
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    dataReceived = true
    self.geolocationError = error as NSError
  }
  
}
