//
//  ExploreCollectionViewCell.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift

class ExploreCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  let viewData = Variable<CPExploreDetailViewData?>(nil)
  
  var disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    viewData.asObservable().filter { $0 != nil }.map { $0! }.subscribeNext {
      self.titleLabel.text = $0.title
      self.backgroundImageView.kf_setImageWithURL(NSURL(string: $0.imageUrl)!)
    }.addDisposableTo(disposeBag)
  }
  
}
