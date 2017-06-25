//
//  FileDownloadOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 12/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import DataRetrievalKit

/**
 Operation requesting data form cahce of network. Usefull for image or other resources.
 
 Actually is a general kind of operations and can be moved to DataRetrievalKit
 */
class CachedNetworkDataRetrievalOperation: NetworkDataRetrievalOperation {
  
  var cache:Bool = false
  override func retriveData() throws {
    
    stage = .requesting
    
    var shouldRequestFromNetwork = true
    var cacheURL:URL? = nil
    
    //Try to retrive data from cache first
    if let request = request, cache {
      let cacheName = String((request as NSURLRequest).hash)
      let cacheDirectory = FileManager.applicationCachesDirectory
      let fileURL = cacheDirectory.appendingPathComponent(cacheName)
      cacheURL = fileURL
      if let content = try? Data(contentsOf: fileURL) {
        data = content
        shouldRequestFromNetwork = false
      }
      
    }
    // Retrieve from network if no file avaialble
    if shouldRequestFromNetwork {
      try super.retriveData()
      // And save it to cahce if needed
      if let fileURL = cacheURL, let fileData = data, false == isCancelled {
        do {
          try fileData.write(to: fileURL, options: .atomic)
        } catch {
          throw DataRetrievalOperationError.internalError(error: error)
        }
      }
    }
  }
  
  
}
