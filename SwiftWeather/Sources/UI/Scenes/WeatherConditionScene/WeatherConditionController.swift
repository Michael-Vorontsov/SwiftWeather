//
//  WeatherConditionController.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 18/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit
import CoreData
import DataRetrievalKit

private let Const = (
  sortKeys : (
    selected : "isSelected",
    current : "isCurrent"
  ),
  wallpaperAnimation : (
      interval : 30.0,
      duration : 1.0
  ),
  backWallpapers : [ "0", "1", "2", "3"] as [String]
)

protocol SelectedRegionPresenter: NSObjectProtocol {
  var selectedRegion: Region? {get set}
}

class WeatherConditionController: UIViewController, DataRequestor, DataPresenter, SelectedRegionPresenter {
  
  
  lazy var dataOperationManager: DataRetrievalOperationManager! = {
    return AppDelegate.sharedAppDelegate.dataOperationManager
  }()
  
  lazy var coreDataManager: CoreDataManager! = {
    return AppDelegate.sharedAppDelegate.coreDataManager
  }()
  
  lazy var resultsController:NSFetchedResultsController! = {
    guard let context = self.coreDataManager?.mainContext else {
      return nil
    }
    
    let request = NSFetchRequest(entityName: Region.entityName)
    request.sortDescriptors = [NSSortDescriptor(key: "isSelected", ascending: false), NSSortDescriptor(key: "isCurrent", ascending: true)]
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
  
  var selectedRegion: Region? {
    didSet {
      if selectedRegion != oldValue {
        if let newRegion = selectedRegion {
          newRegion.isSelected = true
          dataOperationManager.addOperations([ForecastDataOperation(region: newRegion)])
        }
        for controller in childViewControllers {
          if let controller = controller as? SelectedRegionPresenter {
            controller.selectedRegion = selectedRegion
          }
        }
        
        invalidateUI()
      }
    }
  }
  
  var nextWallpaperImageIndex = 0
  
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var regionNameLabel: UILabel!
  @IBOutlet weak var weatherConditionImageView: UIImageView!
  
  @IBOutlet weak var temperatureCaptionLabel: UILabel!
  @IBOutlet weak var humidityCaptionLabel: UILabel!
  @IBOutlet weak var windCaptionLabel: UILabel!
  
  @IBOutlet weak var pressureCaptionLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var pressureLabel: UILabel!
  @IBOutlet weak var windLabel: UILabel!
  @IBOutlet weak var windDirectionLabel: UILabel!
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  
}

// MARK: Overload
extension WeatherConditionController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    weatherDescriptionLabel.font = UIFont.schemeTitleFont
    regionNameLabel.font = UIFont.schemeHeaderFont
    
    temperatureCaptionLabel.font = UIFont.schemeBodyFont
    humidityCaptionLabel.font = UIFont.schemeBodyFont
    pressureCaptionLabel.font = UIFont.schemeBodyFont
    pressureLabel.font = UIFont.schemeBodyFont
    windCaptionLabel.font = UIFont.schemeBodyFont
    temperatureLabel.font = UIFont.schemeBodyFont
    humidityLabel.font = UIFont.schemeBodyFont
    windLabel.font = UIFont.schemeBodyFont
  }

  override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(animated)
    
    selectedRegion = resultsController.fetchedObjects?.first as? Region
    invalidateUI()
    updateBackgroundImage()
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let destinationViewController = segue.destinationViewController as? DataRequestor {
      destinationViewController.dataOperationManager = dataOperationManager
    }
    if let destinationViewController = segue.destinationViewController as? DataPresenter {
      destinationViewController.coreDataManager = coreDataManager
    }
    if let destinationViewController = segue.destinationViewController as? SelectedRegionPresenter {
      destinationViewController.selectedRegion = selectedRegion
    }
  }
  
}

// MARK: -Functions
extension WeatherConditionController {
  
  func updateBackgroundImage() {
    let imageName = Const.backWallpapers[nextWallpaperImageIndex]
    UIView.animateWithDuration(Const.wallpaperAnimation.duration, animations: {
      self.backgroundImageView.alpha = 0.0
    }) { (completed) in
      self.backgroundImageView.image = UIImage(named: imageName)
      UIView.animateWithDuration(Const.wallpaperAnimation.duration) {
        self.backgroundImageView.alpha = 1.0
      }
    }
    
    nextWallpaperImageIndex =  (nextWallpaperImageIndex + 1) % Const.backWallpapers.count
    let selector = #selector(updateBackgroundImage)
    NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: selector, object: nil)
    
    performSelector(selector, withObject: true, afterDelay: Const.wallpaperAnimation.interval)
  }
  
  func invalidateUI() {
    if let selectedRegion = selectedRegion {
      regionNameLabel.text = selectedRegion.name
      let conditions = selectedRegion.currectCondition
      weatherDescriptionLabel.text = conditions?.weatherDescription
      temperatureLabel.text = conditions?.temperature?.stringValue
      humidityLabel.text = conditions?.humidity?.stringValue
      windLabel.text = conditions?.windSpeed?.stringValue
      pressureLabel.text = conditions?.pressure?.stringValue
      
      if let windDir = conditions?.windDirection?.integerValue,
        let windDirection = WindDirection(rawValue:windDir),
        let windAngle = windDirection.angleRawValue {
        windDirectionLabel.hidden = false
        windDirectionLabel.transform = CGAffineTransformMakeRotation(CGFloat(windAngle))
      } else {
        windDirectionLabel.hidden = true
      }
      
    } else {
      weatherDescriptionLabel.text = ""
      regionNameLabel.text = ""
    }
    
    if let imagePath = selectedRegion?.currectCondition?.weatherIconPath {
      weatherConditionImageView.setRemoteImage(imagePath, operationManager: dataOperationManager)
    } else {
      weatherConditionImageView.image = nil
    }
  }
  
}

// MARK: -NSFetchedResultsControllerDelegate
extension WeatherConditionController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.selectedRegion = controller.fetchedObjects?.first as? Region
  }
}


