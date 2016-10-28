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

    func foo() -> Int {
        let i = 5
        return i
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
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.title }
             .bindTo(self.navigationItem.rx.title)
             .addDisposableTo(disposeBag)

    viewModel.filter { $0.photo != nil }
             .map { URL(string: $0.photo!.imageUrl)! }
             .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    self.photoImageView.kf.indicatorType = .activity
                    self.photoImageView.kf.setImage(with: value)
                default:
                    break
                }
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { URL(string: $0.photo!.ownerAvatarUrl)! }
             .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    self.ownerAvatarImageView.kf.setImage(with: value)
                default:
                    break
                }
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.ownerName }
             .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    self.ownerLabel.text = value
                default:
                    break
                }
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.numberOfView }
             .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    self.numberOfViewLabel.text = value
                default:
                    break
                }
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.numberOfComment }
             .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    self.numberOfCommentLabel.text = value
                default:
                    break
                }
             }
             .addDisposableTo(disposeBag)
    
    viewModel.map { $0.comments }
        .bindTo(tableView.rx.items(cellIdentifier: "CommentCell", cellType: PhotoCommentTableViewCell.self)) { row, element, cell in
               cell.viewData.value = element
             }
             .addDisposableTo(disposeBag)
  }
  
  deinit {
    detailController.unsubscribe()
    commentController.unsubscribe()
  }
  
}
