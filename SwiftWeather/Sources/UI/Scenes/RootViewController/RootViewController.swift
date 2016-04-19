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
      UIView.animateWithDuration(0.1) {
        self.view.layoutIfNeeded()
        self.shadowView.alpha = self.menuVisible ? 1.0 : 0.0
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    menuVisible = false
  }
  
}

extension RootViewController: UIGestureRecognizerDelegate {
  
  @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
    var progress:CGFloat = menuVisible ? 1.0 : 0.0
    switch sender.state {
    case .Changed:
      let transition = -sender.translationInView(view).x
      menuPositionContraint.constant = (menuVisible) ? transition :  transition - menuWidth
      progress = 1.0 + (menuPositionContraint.constant / menuWidth)
      
    case .Ended:
      menuVisible = menuWidth / 2.0 > -menuPositionContraint.constant
      progress = menuVisible ? 1.0 : 0.0
    default: break
    }
    
    UIView.animateWithDuration(0.1) {
      self.view.layoutIfNeeded()
      self.shadowView.alpha = progress
    }
  }
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let velocity = gestureRecognizer.velocityInView(view)
      // Begin recognising if horizontal staring velocity greater then vertical one
      return abs(velocity.x) > abs(velocity.y)
    }
    return false
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @IBAction func showMenu(sender:AnyObject) {
    menuVisible = true
  }
  
  @IBAction func hideMenu(sender:AnyObject) {
    menuVisible = false
  }
  
}

extension RootViewController {
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let destinationViewController = segue.destinationViewController as? DataRequestor {
      destinationViewController.dataOperationManager = dataOperationManager
    }
    if let destinationViewController = segue.destinationViewController as? DataPresenter {
      destinationViewController.coreDataManager = coreDataManager
    }
  }
}

// Global action - Responder Chain pattern
extension RootViewController {
  @IBAction func addNewRegion(sender:AnyObject) {
    let addRegionController = AddRegionTableViewController()
    addRegionController.dataOperationManager = dataOperationManager
    addRegionController.coreDataManager = coreDataManager
    self.presentViewController(addRegionController, animated: true, completion: nil)
  }
  
}