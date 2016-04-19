//
//  AddRegionTableViewController.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData
import DataRetrievalKit

private let Consts = (
  headerReuseID : "headerReuseID",
  cellReuseID: "cellId",
  curtain : (
    color : UIColor.schemeHeaderColor,
    alpha : 0.3 as CGFloat
  ),
  searchBarAccessibility : "Search",
  headerHeight : 60.0 as CGFloat // Needed for iOS8
)

class AddRegionTableViewController: UITableViewController, DataPresenter, DataRequestor {
  
  var coreDataManager: CoreDataManager!
  var dataOperationManager: DataRetrievalOperationManager!
  
  lazy var resultsController:NSFetchedResultsController! = {
    guard let context = self.coreDataManager?.mainContext else {
      return nil
    }
    
    let request = NSFetchRequest(entityName: SearchResult.entityName)
    request.sortDescriptors = [NSSortDescriptor(key: "string", ascending: true)]
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
  
}

// MARK: - Overrides
extension AddRegionTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(SearchTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: Consts.headerReuseID)
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Consts.cellReuseID)
    self.clearsSelectionOnViewWillAppear = false
  }
  
  override func viewWillAppear(animated: Bool) {
    if let results = resultsController.fetchedObjects as? [NSManagedObject] where results.count > 0 {
      coreDataManager.mainContext.deleteObjects(results)
    }
    super.viewWillAppear(animated)
  }
}

// MARK: - Actions
extension AddRegionTableViewController {
  
  @IBAction func cancel(sender:AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Table view data source
extension AddRegionTableViewController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultsController?.fetchedObjects?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view =  tableView.dequeueReusableHeaderFooterViewWithIdentifier(Consts.headerReuseID) as? SearchTableViewHeader
    view?.searchBar.delegate = self
    view?.searchBar.becomeFirstResponder()
    view?.searchBar.accessibilityLabel = Consts.searchBarAccessibility
    return view
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Consts.headerHeight
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Consts.cellReuseID, forIndexPath: indexPath)
    guard let searchResult = resultsController.fetchedObjects?[indexPath.row] as? SearchResult else {
      return cell
    }
    cell.textLabel?.text = searchResult.string
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedResult = resultsController.objectAtIndexPath(indexPath)
    let operation = ForecastDataOperation(regionName: selectedResult.string!)
    dataOperationManager.addOperations([operation])
    cancel(tableView)
  }
  
}

// MARK: - UISearchBarDelegate
extension AddRegionTableViewController: UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    self.cancel(searchBar)
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    let operation = GeosearchDataOperation(request: searchBar.text!)
    var curtainView:UIView? = nil
    
    if let window = view.window {
      // Close window by 'Curtain' until data came
      let curtain = UIView(frame: window.bounds)
      curtain.backgroundColor = Consts.curtain.color
      curtain.alpha = Consts.curtain.alpha
      window.addSubview(curtain)
      curtainView = curtain
    }
    
    dataOperationManager.addOperations([operation]) { (success, results, errors) in
      curtainView?.removeFromSuperview()
    }
  }
  
}

// MARK: - NSFetchedResultsControllerDelegate
extension AddRegionTableViewController: NSFetchedResultsControllerDelegate {
  
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

