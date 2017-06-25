//
//  RootViewController.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import DataRetrievalKit

class RootViewController: UIViewController, DataPresenter, DataRequestor {
  
  var dataOperationManager: DataRetrievalOperationManager!
  var coreDataManager: CoreDataManager!
  
  @IBOutlet weak var menuPositionContraint: NSLayoutConstraint!
  @IBOutlet weak var curtainView: UIView!
  @IBOutlet weak var menuContainerView: UIView!
  @IBOutlet weak var shadowView: UIVisualEffectView!
  
  var menuWidth:CGFloat  {
    return self.menuContainerView.frame.size.width
  }
  
  var menuVisible:Bool = false {
    didSet {
      menuPositionContraint.constant = (menuVisible) ? 0 : -menuWidth
      UIView.animate(withDuration: 0.1, animations: {
        self.view.layoutIfNeeded()
        self.shadowView.alpha = self.menuVisible ? 1.0 : 0.0
      }) 
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    menuVisible = false
  }
  
}

extension RootViewController: UIGestureRecognizerDelegate {
  
  @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
    var progress:CGFloat = menuVisible ? 1.0 : 0.0
    switch sender.state {
    case .changed:
      let transition = -sender.translation(in: view).x
      menuPositionContraint.constant = (menuVisible) ? transition :  transition - menuWidth
      progress = 1.0 + (menuPositionContraint.constant / menuWidth)
      
    case .ended:
      menuVisible = menuWidth / 2.0 > -menuPositionContraint.constant
      progress = menuVisible ? 1.0 : 0.0
    default: break
    }
    
    UIView.animate(withDuration: 0.1, animations: {
      self.view.layoutIfNeeded()
      self.shadowView.alpha = progress
    }) 
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let velocity = gestureRecognizer.velocity(in: view)
      // Begin recognising if horizontal staring velocity greater then vertical one
      return abs(velocity.x) > abs(velocity.y)
    }
    return false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @IBAction func showMenu(_ sender:AnyObject) {
    menuVisible = true
  }
  
  @IBAction func hideMenu(_ sender:AnyObject) {
    menuVisible = false
  }
  
}

extension RootViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationViewController = segue.destination as? DataRequestor {
      destinationViewController.dataOperationManager = dataOperationManager
    }
    if let destinationViewController = segue.destination as? DataPresenter {
      destinationViewController.coreDataManager = coreDataManager
    }
  }
}

// Global action - Responder Chain pattern
extension RootViewController {
  @IBAction func addNewRegion(_ sender:AnyObject) {
    let addRegionController = AddRegionTableViewController()
    addRegionController.dataOperationManager = dataOperationManager
    addRegionController.coreDataManager = coreDataManager
    self.present(addRegionController, animated: true, completion: nil)
  }
  
}
