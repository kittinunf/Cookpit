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

  var viewModel: PhotoDetailViewModel!
  
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var ownerAvatarImageView: UIImageView!
  @IBOutlet weak var ownerLabel: UILabel!
  @IBOutlet weak var numberOfViewLabel: UILabel!
  @IBOutlet weak var numberOfCommentLabel: UILabel!
  
  var id: String = "" {
    didSet {
      viewModel = PhotoDetailViewModel(id: id)
    }
  }
  
  let disposeBag = DisposeBag()
  
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
    
    viewModel.images.map { NSURL(string: $0)! }.subscribeNext { [unowned self] in
      self.photoImageView.kf_showIndicatorWhenLoading = true
      self.photoImageView.kf_setImageWithURL($0)
    }.addDisposableTo(disposeBag)
    
    viewModel.ownerAvatarImages.map { NSURL(string: $0)! }.subscribeNext { [unowned self] in
      self.ownerAvatarImageView.kf_setImageWithURL($0)
    }.addDisposableTo(disposeBag)
    
    viewModel.ownerNames.subscribeNext { [unowned self] in
      self.ownerLabel.text = $0
    }.addDisposableTo(disposeBag)
    
    viewModel.views.subscribeNext { [unowned self] in
      self.numberOfViewLabel.text = $0
    }.addDisposableTo(disposeBag)
    
    viewModel.comments.subscribeNext { [unowned self] in
      self.numberOfCommentLabel.text = $0
    }.addDisposableTo(disposeBag)
  }

}
