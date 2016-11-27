//
//  PhotoDataController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/8/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class PhotoDetailDataController {

  private let controller: CPPhotoDetailController
  
  fileprivate let _viewData = Variable<CPPhotoDetailViewData?>(nil)
  
  lazy var viewData: Observable<CPPhotoDetailViewData> = {
    self._viewData.asObservable()
        .filter { $0 != nil }
        .map { $0! as CPPhotoDetailViewData }
        .observeOn(MainScheduler.instance)
  }()
  
  init(id: String) {
    controller = CPPhotoDetailController.create(id)!
    controller.subscribe(self)
  }
  
  func unsubscribe() {
    controller.unsubscribe()
  }
  
  func request() {
    controller.requestDetail()
  }

  deinit {
    controller.unsubscribe()
  }

}

extension PhotoDetailDataController : CPPhotoDetailControllerObserver {

  func onBeginUpdate() {
  }

  func onUpdate(_ viewData: CPPhotoDetailViewData) {
    _viewData.value = viewData
  }

  func onEndUpdate() {
  }

}

class PhotoCommentDataController {

  private let controller: CPPhotoCommentController
  
  fileprivate let _viewData = Variable<CPPhotoCommentViewData?>(nil)
  
  lazy var viewData: Observable<CPPhotoCommentViewData> = {
    self._viewData.asObservable()
        .filter { $0 != nil }
        .map { $0! as CPPhotoCommentViewData }
        .observeOn(MainScheduler.instance)
  }()
  
  init(id: String) {
    controller = CPPhotoCommentController.create(id)!
    controller.subscribe(self)
  }
  
  func unsubscribe() {
    controller.unsubscribe()
  }
  
  func request() {
    controller.requestComments()
  }

  deinit {
    controller.unsubscribe()
  }
  
}

extension PhotoCommentDataController : CPPhotoCommentControllerObserver {

  func onBeginUpdate() {

  }

  func onUpdate(_ viewData: CPPhotoCommentViewData) {
    _viewData.value = viewData
  }

  func onEndUpdate() {
        
  }

}
