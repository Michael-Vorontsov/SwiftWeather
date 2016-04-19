//
//  UIImageView+Extensions.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 12/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import DataRetrievalKit

extension UIImageView {
  
  func setRemoteImage(address:String, operationManager:DataRetrievalOperationManager) {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    let oldColor = backgroundColor
    backgroundColor = UIColor.clearColor()
    self.addSubview(activityIndicator)
    activityIndicator.center = CGPointMake( CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    activityIndicator.startAnimating()
    
    let operation = ImageNetworkOperation(imagePath: address)
    operationManager.addOperations([operation]) { (success, results, errors) in
      activityIndicator.removeFromSuperview()
      if let image = results.first as? UIImage where true == success {
        self.backgroundColor = oldColor
        self.image = image
      }
    }
  }

}
