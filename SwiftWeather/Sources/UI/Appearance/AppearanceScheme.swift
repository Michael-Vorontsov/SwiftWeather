//
//  AppearanceScheme.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 10/04/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

/**
 File designated as single place for Designer palette. All custom fonts, colours, appearance etc. should specified here.
 */

private let Consts = (
  defaultFontName : "Arial",
  size : (
    body: 14.0 as CGFloat,
    selectedBody: 16.0 as CGFloat,
    title : 19.0 as CGFloat,
    header : 17.0 as CGFloat
    ),
  cornerRadius: 10.0 as CGFloat,
  motionKeys : (
    x : "center.x",
    y : "center.y",
    value : -20
  )

)

extension UIView {
  @IBInspectable var cornerRadius:CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }
  
  
  @IBInspectable var parallaxEffect:CGFloat {
    get {
      let motionEffects = self.motionEffects
      for effect in motionEffects {
        guard let effect = effect as? UIMotionEffectGroup,
          let subEffects = effect.motionEffects else {
          continue
        }
        for subEffect in subEffects {
          guard let subEffect = subEffect as? UIInterpolatingMotionEffect where .TiltAlongVerticalAxis == subEffect.type else {
            continue
          }
          return subEffect.maximumRelativeValue as? CGFloat ?? 0.0
        }
      }
      return 0.0
    }
    set {
      guard false == newValue.isZero else {
        // if zero - remove all motion effects
        let motionEffects = self.motionEffects
        for effect in motionEffects {
          self.removeMotionEffect(effect)
        }
        return
      }
      let verticalEffect = UIInterpolatingMotionEffect(keyPath: Consts.motionKeys.y, type: .TiltAlongVerticalAxis)
      verticalEffect.minimumRelativeValue = -parallaxEffect
      verticalEffect.maximumRelativeValue = parallaxEffect
      
      let horizontalEffect = UIInterpolatingMotionEffect(keyPath: Consts.motionKeys.x, type: .TiltAlongHorizontalAxis)
      horizontalEffect.minimumRelativeValue = -parallaxEffect
      horizontalEffect.maximumRelativeValue = parallaxEffect
      
      let group = UIMotionEffectGroup()
      group.motionEffects = [horizontalEffect, verticalEffect]
      
      addMotionEffect(group)
    }
  }

}

extension UIColor {
  @nonobjc static let schemeActionColor:UIColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
  @nonobjc static let schemeDisableColor:UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
  
  @nonobjc static let schemeSelectedTextColor:UIColor = UIColor(red: 0.1, green: 0.4, blue: 0.45, alpha: 1.0)
  @nonobjc static let schemeUnselectedTextColor:UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
  
  @nonobjc static let schemeHeaderColor:UIColor = UIColor(red: 0.1, green: 0.6, blue: 0.5, alpha: 0.5)
}

extension UIFont {
  @nonobjc static let schemeBodyFont:UIFont = UIFont(name: Consts.defaultFontName, size: Consts.size.body)!
  @nonobjc static let schemeSelectedBodyFont:UIFont = UIFont(name: Consts.defaultFontName, size: Consts.size.selectedBody)!
  @nonobjc static let schemeTitleFont:UIFont = UIFont(name: Consts.defaultFontName, size: Consts.size.title)!
  @nonobjc static let schemeHeaderFont:UIFont = UIFont(name: Consts.defaultFontName, size: Consts.size.header)!
}

/**
 Contains static function to setup appearance. Some additional appearance functionality can be added further.
 */
struct AppearanceScheme {
  static func setupApperance() {
    
    let toolbarAppearance = UIToolbar.appearance()
    toolbarAppearance.backgroundColor = UIColor.schemeHeaderColor
  }

}
