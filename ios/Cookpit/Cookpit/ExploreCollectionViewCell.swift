//
//  ExploreCollectionViewCell.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class ExploreCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  let viewData = Variable<CPExploreDetailViewData?>(nil)
  
  let disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    viewData.asObservable().filter { $0 != nil }.map { $0! }.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            self.titleLabel.text = value.title
            self.backgroundImageView.kf.setImage(with: URL(string: value.imageUrl)!)
        default:
            break
        }
    }.addDisposableTo(disposeBag)
  }
  
}
