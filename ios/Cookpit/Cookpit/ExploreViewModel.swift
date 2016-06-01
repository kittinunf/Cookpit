//
//  ExploreViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class ExploreViewModel {

  private let controller = CPExploreController.create()!
  
  private let viewData = Variable<CPExploreViewData?>(nil)
  private let loading = Variable<Bool>(false)
  
  var pageNumber = 0
  
  init() {
    controller.subscribe(self)
  }
  
  // item stream
  lazy var loadings: Observable<Bool> = {
    self.loading.asObservable()
  }()
  
  lazy var errors: Observable<String> = {
    self.viewData.asObservable()
                  .filter { $0 != nil && $0!.error }
                  .distinctUntilChanged { $0!.error }
                  .map { $0!.message }
  }()
  
  lazy var items: Observable<[CPExploreDetailViewData]> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.explores }
  }()
  
  func spacingForSection(section: Int) -> Float {
    return 5
  }
  
  func requestForPage(page: Int) {
    pageNumber = page
    self.controller.request(Int8(page))
  }
  
  func requestForNextPage() {
    requestForPage(pageNumber + 1)
  }
  
  func reset() {
    self.controller.reset()
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}

extension ExploreViewModel : CPExploreControllerObserver {
  @objc func onBeginUpdate() {
    loading.value = true
  }

  @objc func onUpdate(data: CPExploreViewData) {
    viewData.value = data
  }
  
  @objc func onEndUpdate() {
    loading.value = false
  }
}
