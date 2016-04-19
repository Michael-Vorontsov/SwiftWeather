//
//  RegionsTableViewController.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData
import DataRetrievalKit

private let Const = (
  cellID : (
    region : "regionCell",
    new : "addRegion"
  ),
  sortKeys : (
    current : "isCurrent",
    name : "name"
  ),
  localeKeysCurrent : "Current (%@)",
  accessability : (
    edit : "Edit",
    cancel : "Cancel",
    add : "Add"
  )
)


class RegionsTableViewController: UITableViewController , DataPresenter, DataRequestor, SelectedRegionPresenter {
  
  var coreDataManager: CoreDataManager!
  var dataOperationManager: DataRetrievalOperationManager!
  
  var selectedRegion: Region? {
    didSet {
      if selectedRegion != oldValue {
        oldValue?.isSelected = false
        selectedRegion?.isSelected = true
      }
    }
  }
  
  lazy var resultsController:NSFetchedResultsController! = {
    guard let context = self.coreDataManager?.mainContext else {
      return nil
    }
    
    let request = NSFetchRequest(entityName: Region.entityName)
    request.sortDescriptors = [NSSortDescriptor(key: Const.sortKeys.current, ascending: false), NSSortDescriptor(key: Const.sortKeys.name, ascending: true)]
    let resultsController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context ,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    resultsController.delegate = self
    do {
      try resultsController.performFetch()
    } catch {
      assert(false, "Error while executing fetch request: \(error)")
    }
    
    return resultsController
  }()
  
  
  lazy var toolBar:UIToolbar =  {
    let toolbar = UIToolbar(frame: CGRectMake(0,0,0,42))
    return toolbar
  }()
  
  override var editing: Bool {
    didSet {
      if true == editing {
        let editButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(editAction))
        editButton.accessibilityLabel = Const.accessability.cancel
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: nil, action: #selector(RootViewController.addNewRegion))
        addButton.accessibilityLabel = Const.accessability.add
        toolBar.setItems([addButton, editButton], animated: true)
      } else {
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editAction))
        editButton.accessibilityLabel = Const.accessability.edit
        toolBar.setItems([editButton], animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.tableHeaderView = toolBar
    
  }
  
  @IBAction func editAction(sender:AnyObject) {
    editing = !editing
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView?.reloadData()
    editing = false
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultsController?.fetchedObjects?.count ?? 0
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(Const.cellID.region, forIndexPath: indexPath)
    guard
      let fetchedObjects = resultsController.fetchedObjects where fetchedObjects.count > indexPath.row,
      let region = fetchedObjects[indexPath.row] as? Region else {
        return UITableViewCell()
    }
    
    let current = (region.isCurrent?.boolValue) ?? false
    let selected = (region.isSelected?.boolValue) ?? false
    if current {
      cell.textLabel?.text =  NSString(format: NSLocalizedString(Const.localeKeysCurrent, comment: ""), (region.name ?? "")) as String
    } else {
      cell.textLabel?.text = region.name!
    }
    
    cell.textLabel?.textColor =  selected ? UIColor.schemeSelectedTextColor : UIColor.schemeUnselectedTextColor
    cell.textLabel?.font =  selected ?  UIFont.schemeSelectedBodyFont : UIFont.schemeBodyFont
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard
      let fetchedObjects = resultsController.fetchedObjects where fetchedObjects.count > indexPath.row,
      let region = fetchedObjects[indexPath.row] as? Region else {
        return
    }
    selectedRegion = region
    UIApplication.sharedApplication().sendAction(#selector(RootViewController.hideMenu(_:)), to: nil, from: self, forEvent: nil)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return indexPath.row > 0
  }
  
  override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return indexPath.row > 0
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    guard
      let fetchedObjects = resultsController.fetchedObjects where fetchedObjects.count > indexPath.row,
      let region = fetchedObjects[indexPath.row] as? Region else {
        return
    }
    let context = region.managedObjectContext!
    context.deleteObject(region)
    context.save(recursive: true)
    
  }
  
}

extension RegionsTableViewController:NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
    case .Update:
      tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Move:
      tableView.reloadRowsAtIndexPaths([indexPath!, newIndexPath!], withRowAnimation: .Right)
    }
  }
  
}
