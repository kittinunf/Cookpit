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
    
    viewData.asObservable().filter { $0 != nil }.map { $0! }.subscribeNext { [unowned self] in
      self.commentOwnerAvatarImageView.kf_setImageWithURL(NSURL(string: $0.ownerAvatarUrl)!)
      self.commentOwnerNameLabel.text = $0.ownerName
      self.commentTextLabel.text = $0.text
    }.addDisposableTo(disposeBag)
  }
  
}
