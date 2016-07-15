//
//  MapDataController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/15/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation

class MapDataController {
  
  let controller: CPMapController
  
  lazy var mapToken: String = {
    CPMapController.mapToken()
  }()
  
  init() {
    controller = CPMapController.create()!
  }
    
}

extension MapDataController : CPMapControllerObserver {

  @objc func onBeginUpdate() {

  }
  
  @objc func onUpdate(viewDate: CPMapViewData) {

  }
  
  @objc func onEndUpdate() {

  }
  
}