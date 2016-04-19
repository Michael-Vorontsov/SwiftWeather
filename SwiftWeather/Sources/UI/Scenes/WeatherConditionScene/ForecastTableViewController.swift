//
//  ForecastTableViewController.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import DataRetrievalKit
import CoreData

private let Consts = (
  cellId : "ForecastCell",
  dateFormateTemplate : "EdMMM",
  sortKey: "date",
  predicate: "region == %@ AND date > %@"
)

extension DailyForecast {
  
  func descriptionString() -> String {
    var resultString = ""
    resultString += "\(minTemp!.stringValue) - \(maxTemp!.stringValue)"
    return resultString
  }
  
}

class ForecastTableViewController: UITableViewController, DataPresenter, DataRequestor, SelectedRegionPresenter {
  
  var coreDataManager: CoreDataManager!
  var dataOperationManager: DataRetrievalOperationManager!
  var selectedRegion:Region? {
    didSet {
      resultsController = nil
      tableView.reloadData()
    }
  }
  
  lazy var dateFormatter:NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate(Consts.dateFormateTemplate, options: 0, locale: NSLocale.currentLocale())
    return dateFormatter
  }()
  
  lazy var resultsController:NSFetchedResultsController! = {
    guard let context = self.coreDataManager?.mainContext ,
      let region = self.selectedRegion else {
        return nil
    }
    
    let request = NSFetchRequest(entityName: DailyForecast.entityName)
    request.predicate = NSPredicate(format: Consts.predicate, region, NSDate())
    request.sortDescriptors = [NSSortDescriptor(key: Consts.sortKey, ascending: true)]
    
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

//MARK: -Overrides
extension ForecastTableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
    self.refreshControl = refreshControl
  }
  
  @IBAction func refresh(sender:AnyObject) {
    guard let name = selectedRegion?.name else {
      self.refreshControl?.endRefreshing()
      return
    }
    dataOperationManager.addOperations([ForecastDataOperation(regionName: name)]) {[weak self] (success, results, errors) in
      self?.refreshControl?.endRefreshing()
    }
  }
  
}

//MARK: -UITableViewDataSource
extension ForecastTableViewController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let resultsCount = resultsController?.fetchedObjects?.count where resultsCount > 0 {
      tableView.backgroundView = nil
      return resultsCount
    }
    let label = UILabel(frame: view.bounds)
    label.font = UIFont.schemeBodyFont
    label.text = NSLocalizedString("No forecast available now.\n Try again later", comment: "")
    label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    label.numberOfLines = 0
    label.textAlignment = .Center
    tableView.backgroundView = label
    
    return  0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Consts.cellId, forIndexPath: indexPath)
    guard let forecast = resultsController?.objectAtIndexPath(indexPath) as? DailyForecast,
      let date = forecast.date
      else {
        cell.textLabel?.text = "Error: unable to fetch DailyForecast at indexpat:\(indexPath)"
        return cell
    }
    
    cell.textLabel?.text = dateFormatter.stringFromDate(date)
    cell.detailTextLabel?.text = forecast.descriptionString()
    return cell
  }
  
}

//MARK: -NSFetchedResultsControllerDelegate
extension ForecastTableViewController: NSFetchedResultsControllerDelegate {
  
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