//
//  PhotoDetailViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/2/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

enum PhotoViewModelCommand {

  case SetPhoto(photo: CPPhotoDetailViewData)
  case SetComments(comments: [CPPhotoCommentDetailViewData])
  
}

struct PhotoViewModel {

  let photo: CPPhotoDetailViewData?
  let comments: [CPPhotoCommentDetailViewData]
  
  func executeCommand(command: PhotoViewModelCommand) -> PhotoViewModel {
    switch command {
    case let .SetPhoto(photo):
        return PhotoViewModel(photo: photo, comments: comments)
    case let .SetComments(comments):
        return PhotoViewModel(photo: photo, comments: comments)
    }
  }
  
}
