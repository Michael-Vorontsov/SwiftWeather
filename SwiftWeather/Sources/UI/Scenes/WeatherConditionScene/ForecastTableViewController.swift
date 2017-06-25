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
  
  lazy var dateFormatter:DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: Consts.dateFormateTemplate, options: 0, locale: Locale.current)
    return dateFormatter
  }()
  
  lazy var resultsController:NSFetchedResultsController<DailyForecast>! = {
    guard let context = self.coreDataManager?.mainContext ,
      let region = self.selectedRegion else {
        return nil
    }
    
    let request = NSFetchRequest<DailyForecast>(entityName: DailyForecast.entityName)
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
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    self.refreshControl = refreshControl
  }
  
  @IBAction func refresh(_ sender:AnyObject) {
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
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let resultsCount = resultsController?.fetchedObjects?.count, resultsCount > 0 {
      tableView.backgroundView = nil
      return resultsCount
    }

    // Show placholder if no forecast available.
    if nil == tableView.backgroundView {
      let label = UILabel(frame: view.bounds)
      label.font = UIFont.schemeBodyFont
      label.text = NSLocalizedString("No forecast available now.\n Try again later", comment: "")
      label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      label.numberOfLines = 0
      label.textAlignment = .center
      tableView.backgroundView = label
    }
    
    return  0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Consts.cellId, for: indexPath)
    guard
      let forecast = resultsController?.object(at: indexPath),
      let date = forecast.date
      else {
        cell.textLabel?.text = "Error: unable to fetch DailyForecast at indexpat:\(indexPath)"
        return cell
    }
    
    cell.textLabel?.text = dateFormatter.string(from: date)
    cell.detailTextLabel?.text = forecast.descriptionString()
    return cell
  }
  
}

//MARK: -NSFetchedResultsControllerDelegate
extension ForecastTableViewController: NSFetchedResultsControllerDelegate {
  
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
