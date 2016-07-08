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
  
  private var detailDataController: PhotoDetailDataController!
  private var commentDataController: PhotoCommentDataController!
  
  private let disposeBag = DisposeBag()
  
  var id: String = "" {
    didSet {
        detailDataController = PhotoDetailDataController(id: id)
        commentDataController = PhotoCommentDataController(id: id)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
    bindings()
  }
  
  func configureViews() {
    guard let navigationBar = self.navigationController?.navigationBar else { return }
    navigationBar.tintColor = UIColor.lightGrayColor()
  }
  
  func bindings() {
    detailDataController.request()
    commentDataController.request()
    
    let loadDetailCommand = detailDataController.viewData.map { PhotoViewModelCommand.SetPhoto(photo: $0) }
    let loadCommentCommand = commentDataController.viewData.map { PhotoViewModelCommand.SetComments(comments: $0.comments) }
    
    let viewModel = Observable.of(loadDetailCommand, loadCommentCommand)
                              .merge()
                              .scan(PhotoViewModel(photo: nil, comments: [])) { viewModel, command in
                                viewModel.executeCommand(command)
                              }
    
    viewModel.filter { $0.photo != nil }
             .map { NSURL(string: $0.photo!.imageUrl)! }
             .subscribeNext { [unowned self] url in
               self.photoImageView.kf_showIndicatorWhenLoading = true
               self.photoImageView.kf_setImageWithURL(url)
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { NSURL(string: $0.photo!.ownerAvatarUrl)! }
             .subscribeNext { [unowned self] url in
               self.ownerAvatarImageView.kf_setImageWithURL(url)
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.ownerName }
             .subscribeNext { [unowned self] text in
               self.ownerLabel.text = text
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.numberOfView }
             .subscribeNext { [unowned self] text in
               self.numberOfViewLabel.text = text
             }
             .addDisposableTo(disposeBag)
    
    viewModel.filter { $0.photo != nil }
             .map { $0.photo!.numberOfComment }
             .subscribeNext { [unowned self] text in
               self.numberOfCommentLabel.text = text
             }
             .addDisposableTo(disposeBag)
    
    viewModel.map { $0.comments }
             .bindTo(tableView.rx_itemsWithCellIdentifier("CommentCell", cellType: PhotoCommentTableViewCell.self)) { row, element, cell in
               cell.viewData.value = element
             }
             .addDisposableTo(disposeBag)
  }
  
}
