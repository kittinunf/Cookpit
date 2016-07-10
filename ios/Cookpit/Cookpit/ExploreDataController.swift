//
//  ExploreDataController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/7/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class ExploreDataController {

  private let controller = CPExploreController.create()!
  
  private let _viewData = Variable<CPExploreViewData?>(nil)
  
  lazy var viewData: Observable<CPExploreViewData> = {
    self._viewData.asObservable()
      .filter { $0 != nil }
      .map { $0! as CPExploreViewData }
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
  }()
  
  private let _loadings = Variable(false)
  
  lazy var loadings: Observable<Bool> = {
    self._loadings.asObservable()
        .observeOn(MainScheduler.instance)
  }()
  
  lazy var errors: Observable<String> = {
    self._viewData.asObservable()
      .filter { $0 != nil && $0!.error }
      .distinctUntilChanged { $0!.error }
      .map { $0!.message }
      .observeOn(MainScheduler.instance)
  }()
  
  var currentPage: Int = 1
  
  init() {
    controller.subscribe(self)
  }
  
  func unsubscribe() {
    controller.unsubscribe()
  }
  
  func reset() {
    currentPage = 1
    controller.reset()
  }
  
  func request(page: Int) {
    currentPage = page
    
    dispatchAsync({
      self.controller.request(Int8(page))
    })
  }
  
  func requestNextPage() {
    if !_loadings.value {
      request(currentPage + 1)
    }
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}

extension ExploreDataController : CPExploreControllerObserver {
    
  @objc func onBeginUpdate() {
    _loadings.value = true
  }
  
  @objc func onUpdate(viewData: CPExploreViewData) {
    _viewData.value = viewData
  }
  
  @objc func onEndUpdate() {
    _loadings.value = false
  }
  
}
