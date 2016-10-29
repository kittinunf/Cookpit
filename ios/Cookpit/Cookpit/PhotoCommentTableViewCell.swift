//
//  PhotoCommentTableViewCell.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/3/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class PhotoCommentTableViewCell : UITableViewCell {
  
  @IBOutlet weak var commentOwnerAvatarImageView: UIImageView!
  @IBOutlet weak var commentOwnerNameLabel: UILabel!
  @IBOutlet weak var commentTextLabel: UILabel!
  
  let viewData = Variable<CPPhotoCommentDetailViewData?>(nil)
  
  let disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    viewData.asObservable().filter { $0 != nil }.map { $0! }.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            self.commentOwnerAvatarImageView.kf.setImage(with: URL(string: value.ownerAvatarUrl)!)
            self.commentOwnerNameLabel.text = value.ownerName
            self.commentTextLabel.text = value.text
        default:
            break
        }
    }.addDisposableTo(disposeBag)
  }
  
}
