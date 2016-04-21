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
    
    stage = .Requesting
    
    var shouldRequestFromNetwork = true
    var cacheURL:NSURL? = nil
    
    //Try to retrive data from cache first
    if let request = request where cache {
      let cacheName = String(request.hash)
      let cacheDirectory = NSFileManager.applicationCachesDirectory
      let fileURL = cacheDirectory.URLByAppendingPathComponent(cacheName)
      cacheURL = fileURL
      if let content = NSData(contentsOfURL: fileURL) {
        data = content
        shouldRequestFromNetwork = false
      }
      
    }
    // Retrieve from network if no file avaialble
    if shouldRequestFromNetwork {
      try super.retriveData()
      // And save it to cahce if needed
      if let fileURL = cacheURL, let fileData = data where false == cancelled {
        do {
          try fileData.writeToURL(fileURL, options: .DataWritingAtomic)
        } catch {
          throw DataRetrievalOperationError.InternalError(error: error)
        }
      }
    }
  }
  
  
}
