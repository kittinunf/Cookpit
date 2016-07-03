//
//  PhotoDetailViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/2/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class PhotoViewModel {

  let photoId: String
  
  private let detailSubViewModel: PhotoDetailSubViewModel
  private let commentSubViewModel: PhotoCommentSubViewModel
  
  lazy var images: Observable<String> = {
    self.detailSubViewModel.viewData.filter { $0 != nil }.map { $0!.imageUrl }
  }()
  
  lazy var ownerNames: Observable<String> = {
    self.detailSubViewModel.viewData.filter { $0 != nil }.map { $0!.ownerName }
  }()
  
  lazy var ownerAvatarImages: Observable<String> = {
    self.detailSubViewModel.viewData.filter { $0 != nil }.map { $0!.ownerAvatarUrl }
  }()
  
  lazy var views: Observable<String> = {
    self.detailSubViewModel.viewData.filter { $0 != nil }.map { $0!.numberOfView }
  }()
  
  lazy var commentCounts: Observable<String> = {
    self.detailSubViewModel.viewData.filter { $0 != nil }.map { $0!.numberOfComment }
  }()
  
  lazy var comments: Observable<[CPPhotoCommentDetailViewData]> = {
    self.commentSubViewModel.viewData.filter { $0 != nil }.map { $0!.comments }
  }()

  init(id: String) {
    photoId = id
    detailSubViewModel = PhotoDetailSubViewModel(id: id)
    commentSubViewModel = PhotoCommentSubViewModel(id: id)
  }
  
  func request() {
    detailSubViewModel.requestDetail()
    commentSubViewModel.requestComment()
  }
  
}

class PhotoDetailSubViewModel : CPPhotoDetailControllerObserver {

  let detailController: CPPhotoDetailController

  private let detailViewData = Variable<CPPhotoDetailViewData?>(nil)
  
  lazy var viewData: Observable<CPPhotoDetailViewData?> = {
    self.detailViewData.asObservable()
  }()
  
  init(id: String) {
    detailController = CPPhotoDetailController.create(id)!
    detailController.subscribe(self)
  }
  
  @objc func onBeginUpdate() {

  }
  
  @objc func onUpdate(viewData: CPPhotoDetailViewData) {
    detailViewData.value = viewData
  }
  
  @objc func onEndUpdate() {

  }
  
  func requestDetail() {
    detailController.requestDetail()
  }
  
  deinit {
    detailController.unsubscribe()
  }
  
}

class PhotoCommentSubViewModel : CPPhotoCommentControllerObserver {

  let commentController: CPPhotoCommentController

  private let commentViewData = Variable<CPPhotoCommentViewData?>(nil)
  
  lazy var viewData: Observable<CPPhotoCommentViewData?> = {
    self.commentViewData.asObservable()
  }()
  
  init(id: String) {
    commentController = CPPhotoCommentController.create(id)!
    commentController.subscribe(self)
  }

  @objc func onBeginUpdate() {

  }
  
  @objc func onUpdate(viewData: CPPhotoCommentViewData) {
    commentViewData.value = viewData
  }
  
  @objc func onEndUpdate() {

  }
  
  func requestComment() {
    commentController.requestComments()
  }
  
  deinit {
    commentController.unsubscribe()
  }
  
}

