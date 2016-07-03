//
//  PhotoDetailViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/2/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class PhotoDetailViewModel {

  let photoId: String
  
  let detailController: CPPhotoDetailController
  
  private let viewData = Variable<CPPhotoDetailViewData?>(nil)
  
  lazy var images: Observable<String> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.imageUrl }
  }()
  
  lazy var ownerNames: Observable<String> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.ownerName }
  }()
  
  lazy var ownerAvatarImages: Observable<String> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.ownerAvatarUrl }
  }()
  
  lazy var views: Observable<String> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.numberOfView }
  }()
  
  lazy var comments: Observable<String> = {
    self.viewData.asObservable().filter { $0 != nil }.map { $0!.numberOfComment }
  }()

  init(id: String) {
    
    photoId = id
    detailController = CPPhotoDetailController.create(id)!
    
    detailController.subscribe(self)
    requestDetail()
  }
  
  func requestDetail() {
    detailController.requestDetail()
  }
  
}

extension PhotoDetailViewModel : CPPhotoDetailControllerObserver {

  @objc func onBeginUpdate() {
  }

  @objc func onUpdate(data: CPPhotoDetailViewData) {
    viewData.value = data
  }
  
  @objc func onEndUpdate() {
  }
  
}
