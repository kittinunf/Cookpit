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
    
    viewData.asObservable().filter { $0 != nil }
        .map { $0! }
        .subscribe(onNext :{ [unowned self] value in
          self.backgroundImageView.kf.setImage(with: URL(string: value.imageUrl)!)
        }).addDisposableTo(disposeBag)
  }
  
}
