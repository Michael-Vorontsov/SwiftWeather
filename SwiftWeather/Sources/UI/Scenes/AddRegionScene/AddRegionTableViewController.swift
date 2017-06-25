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
  
  lazy var resultsController:NSFetchedResultsController<SearchResult>! = {
    guard let context = self.coreDataManager?.mainContext else {
      return nil
    }
    
    let request = NSFetchRequest<SearchResult>(entityName: SearchResult.entityName)
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
    tableView.register(SearchTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: Consts.headerReuseID)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.cellReuseID)
    self.clearsSelectionOnViewWillAppear = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let results = resultsController.fetchedObjects, results.count > 0 {
      coreDataManager.mainContext.deleteObjects(results)
    }
    super.viewWillAppear(animated)
  }
}

// MARK: - Actions
extension AddRegionTableViewController {
  
  @IBAction func cancel(_ sender:AnyObject) {
    tableView.backgroundView = nil
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Table view data source
extension AddRegionTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultsController?.fetchedObjects?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view =  tableView.dequeueReusableHeaderFooterView(withIdentifier: Consts.headerReuseID) as? SearchTableViewHeader
    view?.searchBar.delegate = self
    view?.searchBar.becomeFirstResponder()
    view?.searchBar.accessibilityLabel = Consts.searchBarAccessibility
    return view
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Consts.headerHeight
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Consts.cellReuseID, for: indexPath)
    guard let searchResult = resultsController.fetchedObjects?[indexPath.row] else {
      return cell
    }
    cell.textLabel?.text = searchResult.string
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedResult = resultsController.object(at: indexPath)
    let operation = ForecastDataOperation(regionName: selectedResult.string!)
    

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.startAnimating()
    tableView.backgroundView = activityIndicator
    
    dataOperationManager.addOperations([operation]) { [weak self] _ in
      defer {
        self?.cancel(tableView)

      }
      
      guard let regionID = operation.results?.last as? NSManagedObjectID,
        let context = self?.coreDataManager.dataContext else {
        return
      }
      context.perform {
        guard let region = context.object(with: regionID) as? Region else {
          return
        }
        let oldSelectedRegion = Region.selectedRegion(context: context)
        oldSelectedRegion?.isSelected = false
        region.isSelected = true
        context.save(recursive: false)
        }
      }
  }
  
}

// MARK: - UISearchBarDelegate
extension AddRegionTableViewController: UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    self.cancel(searchBar)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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

