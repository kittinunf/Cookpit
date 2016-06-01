//
//  SearchTableViewCell.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class SearchTableViewCell : UITableViewCell {
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  
  let viewData = Variable<CPSearchDetailViewData?>(nil)
  
  let disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    viewData.asObservable().filter { $0 != nil }.map { $0! }.subscribeNext { [unowned self] in
      self.backgroundImageView.kf_setImageWithURL(NSURL(string: $0.imageUrl)!)
    }.addDisposableTo(disposeBag)
  }
  
}