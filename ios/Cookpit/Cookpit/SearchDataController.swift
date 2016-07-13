//
//  SearchDataController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/7/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class SearchDataController {

  private let controller = CPSearchController.create()!
  
  private let _viewData = Variable<CPSearchViewData?>(nil)
  
  lazy var viewData: Observable<CPSearchViewData> = {
    self._viewData.asObservable()
      .filter { $0 != nil }
      .map { $0! as CPSearchViewData }
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
  }()
  
  private let _recentItems = Variable([String]())
  
  lazy var recentItems: Observable<[String]> = {
    self._recentItems.asObservable()
      .observeOn(MainScheduler.instance)
  }()
  
  private let _loadings = Variable(false)
  
  lazy var loadings: Observable<Bool> = {
    self._loadings.asObservable()
      .observeOn(MainScheduler.instance)
  }()
  
  lazy var errors: Observable<String> = {
    self._viewData.asObservable()
      .filter { $0 != nil }
      .map { $0! as CPSearchViewData }
      .filter { $0.error }
      .distinctUntilChanged()
      .map { $0.message }
      .observeOn(MainScheduler.instance)
  }()
  
  init() {
    controller.subscribe(self)
  }
  
  func unsubscribe() {
    controller.unsubscribe()
  }
  
  func fetchRecents() {
    let items = controller.fetchRecents()
    _recentItems.value = items
  }
  
  func searchWith(key: String) {
    controller.reset()
    searchWith(key, page: 1)
  }
  
  private func searchWith(key: String, page: Int) {
    self.controller.search(key, page: Int8(page))
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}

extension SearchDataController : CPSearchControllerObserver {

  @objc func onBeginUpdate() {
    _loadings.value = true
  }
  
  @objc func onUpdate(viewData: CPSearchViewData) {
    _viewData.value = viewData
  }
  
  @objc func onEndUpdate() {
    _loadings.value = false
  }
  
}
