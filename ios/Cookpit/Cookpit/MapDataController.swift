// //  MapDataController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/15/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class MapDataController : CPMapControllerObserver {
  
  let controller: CPMapController
  
  lazy var mapToken: String = {
    CPMapController.mapToken()
  }()
  
  private let _viewData = Variable<CPMapViewData?>(nil)
  
  lazy var viewData: Observable<CPMapViewData> = {
    self._viewData.asObservable()
        .filter { $0 != nil }
        .map { $0! as CPMapViewData }
        .observeOn(MainScheduler.instance)
  }()
  
  init() {
    controller = CPMapController.create()!
    controller.subscribe(self)
  }
  
  func unsubscribe() {
    controller.unsubscribe()
  }
  
  func request() {
    controller.request()
  }
   
    func onBeginUpdate() {

    }

    func onUpdate(_ data: CPMapViewData) {
        _viewData.value = data
    }

    func onEndUpdate() {
        
    }
    
}
