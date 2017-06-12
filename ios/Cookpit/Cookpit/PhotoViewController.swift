//
//  PhotoViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/2/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoViewController: UIViewController {

  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var ownerAvatarImageView: UIImageView!
  @IBOutlet weak var ownerLabel: UILabel!
  @IBOutlet weak var numberOfViewLabel: UILabel!
  @IBOutlet weak var numberOfCommentLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  private var detailController: PhotoDetailDataController!
  private var commentController: PhotoCommentDataController!
  
  private let disposeBag = DisposeBag()
  
  var id: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    detailController = PhotoDetailDataController(id: id)
    commentController = PhotoCommentDataController(id: id)
    
    bindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
  }

  func bindings() {
    let scheduler = SerialDispatchQueueScheduler(qos: .background)

    Observable.deferred { [unowned self] in
          Observable.just(self.detailController.request())
        }
      .subscribeOn(scheduler)
      .publish()
      .connect()
      .addDisposableTo(disposeBag)

    Observable.deferred { [unowned self] in
          Observable.just(self.commentController.request())
        }
      .subscribeOn(scheduler)
      .publish()
      .connect()
      .addDisposableTo(disposeBag)
    
    let loadDetailCommand = detailController.viewData.map {
        PhotoViewModelCommand.SetPhoto(photo: $0)
    }
    let loadCommentCommand = commentController.viewData.map {
        PhotoViewModelCommand.SetComments(comments: $0.comments)
    }

    let viewModel = Observable.of(loadDetailCommand, loadCommentCommand)
                              .merge()
                              .scan(PhotoViewModel(photo: nil, comments: [])) { viewModel, command in
                                viewModel.executeCommand(command: command)
                              }
                              .shareReplay(2)
                              .observeOn(MainScheduler.instance)

    let validPhotoViewModel = viewModel.filter { $0.photo != nil && $0.photo?.error == false }

    validPhotoViewModel.map { $0.photo!.title }
      .bind(to: self.navigationItem.rx.title)
      .addDisposableTo(disposeBag)

    validPhotoViewModel.map { URL(string: $0.photo!.imageUrl)! }
      .subscribe(onNext: { [unowned self] value in
        self.photoImageView.kf.indicatorType = .activity
        self.photoImageView.kf.setImage(with: value)
      }).addDisposableTo(disposeBag)
    
    validPhotoViewModel.map { URL(string: $0.photo!.ownerAvatarUrl)! }
      .subscribe(onNext: { [unowned self] value in
        self.ownerAvatarImageView.kf.setImage(with: value)
      }).addDisposableTo(disposeBag)
    
    validPhotoViewModel.map { $0.photo!.ownerName }
      .bind(to: self.ownerLabel.rx.text)
      .addDisposableTo(disposeBag)
    
    validPhotoViewModel.map { $0.photo!.numberOfView }
      .bind(to: self.numberOfViewLabel.rx.text)
      .addDisposableTo(disposeBag)
    
    validPhotoViewModel.map { $0.photo!.numberOfComment }
      .bind(to: self.numberOfCommentLabel.rx.text)
      .addDisposableTo(disposeBag)

    viewModel.map { $0.comments }
      .bind(to:
        tableView.rx.items(cellIdentifier: "CommentCell", cellType: PhotoCommentTableViewCell.self)) { row, element, cell in
          cell.viewData.value = element
        }
      .addDisposableTo(disposeBag)
  }
  
  deinit {
    detailController.unsubscribe()
    commentController.unsubscribe()
  }
  
}
