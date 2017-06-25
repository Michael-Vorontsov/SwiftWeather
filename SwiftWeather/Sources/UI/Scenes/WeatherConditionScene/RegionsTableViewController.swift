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
  
  lazy var resultsController:NSFetchedResultsController<Region>! = {
//    guard let context = self.coreDataManager?.mainContext else {
//      return nil
//    }
    let context = self.coreDataManager!.mainContext
    
    let request = NSFetchRequest<Region>(entityName: Region.entityName)
    request.sortDescriptors = [
      NSSortDescriptor(
        key: Const.sortKeys.current,
        ascending: false
      ),
      NSSortDescriptor(
        key: Const.sortKeys.name,
        ascending: true
      )]
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
    let toolbar = UIToolbar(frame: CGRect(x: 0,y: 0,width: 0,height: 42))
    return toolbar
  }()
  
  override var isEditing: Bool {
    didSet {
      if true == isEditing {
        let editButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(editAction))
        editButton.accessibilityLabel = Const.accessability.cancel
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(RootViewController.addNewRegion))
        addButton.accessibilityLabel = Const.accessability.add
        toolBar.setItems([addButton, editButton], animated: true)
      } else {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
        editButton.accessibilityLabel = Const.accessability.edit
        toolBar.setItems([editButton], animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.tableHeaderView = toolBar
    
  }
  
  @IBAction func editAction(_ sender:AnyObject) {
    isEditing = !isEditing
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView?.reloadData()
    isEditing = false
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultsController?.fetchedObjects?.count ?? 0
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellID.region, for: indexPath)
    guard
      let fetchedObjects = resultsController.fetchedObjects, fetchedObjects.count > indexPath.row else {
        return UITableViewCell()
    }
    let region = fetchedObjects[indexPath.row]
    
    let current = (region.isCurrent?.boolValue) ?? false
    let selected = (region.isSelected?.boolValue) ?? false
    if current {
      cell.textLabel?.text =  String(format: NSLocalizedString(Const.localeKeysCurrent, comment: ""), (region.name ?? ""))
    } else {
      cell.textLabel?.text = region.name!
    }
    
    cell.textLabel?.textColor =  selected ? UIColor.schemeSelectedTextColor : UIColor.schemeUnselectedTextColor
    cell.textLabel?.font =  selected ?  UIFont.schemeSelectedBodyFont : UIFont.schemeBodyFont
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard
      let fetchedObjects = resultsController.fetchedObjects, fetchedObjects.count > indexPath.row else {
        return
    }
    let region = fetchedObjects[indexPath.row]
    selectedRegion = region
    // Sending selector to responder chain
    UIApplication.shared.sendAction(#selector(RootViewController.hideMenu(_:)), to: nil, from: self, for: nil)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row > 0
  }
  
  override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row > 0
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard
      let fetchedObjects = resultsController.fetchedObjects, fetchedObjects.count > indexPath.row,
      let region = fetchedObjects[indexPath.row] as? Region else {
        return
    }
    let context = region.managedObjectContext!
    context.delete(region)
    context.save(recursive: true)
    
  }
  
}

extension RegionsTableViewController:NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .left)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .left)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .fade)
    case .move:
      tableView.reloadRows(at: [indexPath!, newIndexPath!], with: .right)
    }
  }
  
}
