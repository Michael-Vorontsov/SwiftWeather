//
//  SearchTableViewCell.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 11/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

protocol CellWithNib {
  static var nib: UINib {get}
  
}

extension CellWithNib where Self: UITableViewHeaderFooterView {
  
  static var nib:UINib {
    let name = NSStringFromClass(Self).componentsSeparatedByString(".").last ?? ""
    return UINib(nibName: name, bundle: nil)
  }
  
}

class SearchTableViewHeader: UITableViewHeaderFooterView, CellWithNib {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    searchBar.showsCancelButton = true
    
    // Initialization code
  }
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  
}
