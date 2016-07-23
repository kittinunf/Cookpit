//
//  MapViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/17/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import Mapbox

enum MapViewModelCommand {
  
  case SetItems(items: [CPMapDetailViewData])
  
}

struct MapViewModel {

  let items: [CPMapDetailViewData]
  
  func executeCommand(command: MapViewModelCommand) -> MapViewModel {
    switch command {
    case let .SetItems(items):
      return MapViewModel(items: items)
    }
  }
  
}

extension CPMapDetailViewData : MGLAnnotation {

  public var coordinate: CLLocationCoordinate2D {
    return location.coordinate2D()
  }
  
  public var title: String? {
    return text
  }
  
}