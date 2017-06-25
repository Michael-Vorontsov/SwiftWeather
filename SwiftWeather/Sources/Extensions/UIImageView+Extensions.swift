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
  
  func setRemoteImage(_ address:String, operationManager:DataRetrievalOperationManager) {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let oldColor = backgroundColor
    backgroundColor = UIColor.clear
    self.addSubview(activityIndicator)
    activityIndicator.center = CGPoint( x: self.bounds.midX, y: self.bounds.midY)
    activityIndicator.startAnimating()
    
    let operation = ImageNetworkOperation(imagePath: address)
    operationManager.addOperations([operation]) { (success, results, errors) in
      activityIndicator.removeFromSuperview()
      if let image = results.first as? UIImage, true == success {
        self.backgroundColor = oldColor
        self.image = image
      }
    }
  }

}
