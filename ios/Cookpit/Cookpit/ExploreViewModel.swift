//
//  ExploreViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

enum ExploreViewModelCommand {

  case SetItems(items: [CPExploreDetailViewData])
  
}

struct ExploreViewModel {

  let items: [CPExploreDetailViewData]
  
  func executeCommand(command: ExploreViewModelCommand) -> ExploreViewModel {
    switch command {
    case let .SetItems(items):
        return ExploreViewModel(items: items)
    }
  }
  
}

class ExploreController : CPExploreControllerObserver {

  private let controller = CPExploreController.create()!
  
  private let _viewData = Variable<CPExploreViewData?>(nil)
  
  lazy var viewData: Observable<CPExploreViewData> = {
    self._viewData.asObservable()
      .filter { $0 != nil }
      .map { $0! as CPExploreViewData }
      .distinctUntilChanged()
  }()
  
  private let _loadings = Variable(false)
  
  lazy var loadings: Observable<Bool> = {
    self._loadings.asObservable()
  }()
  
  lazy var errors: Observable<String> = {
    self._viewData.asObservable()
      .filter { $0 != nil && $0!.error }
      .distinctUntilChanged { $0!.error }
      .map { $0!.message }
  }()
  
  var currentPage: Int = 1
  
  init() {
    controller.subscribe(self)
  }
  
  func reset() {
    currentPage = 1
    controller.reset()
  }
  
  func request(page: Int) {
    currentPage = page
    controller.request(Int8(page))
  }
  
  func requestNextPage() {
    if !_loadings.value {
      request(currentPage + 1)
    }
  }
  
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