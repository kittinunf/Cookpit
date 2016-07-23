//
//  NSValue+Coordinate2D.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/17/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import CoreLocation

extension NSValue {

  func coordinate2D() -> CLLocationCoordinate2D {
    var coordinate = CLLocationCoordinate2D()
    self.getValue(&coordinate)
    return coordinate
  }
  
}
