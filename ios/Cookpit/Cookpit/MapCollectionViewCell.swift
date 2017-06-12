//
//  MapCollectionViewCell.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/17/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class MapCollectionViewCell : UICollectionViewCell {

  @IBOutlet weak var photoImageView: UIImageView!
  
  let viewData = Variable<CPMapDetailViewData?>(nil)
  
  private let disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    viewData.asObservable()
        .filter { $0 != nil }
        .map { $0! }
        .subscribe(onNext: { [unowned self] value in
          self.photoImageView.kf.setImage(with: URL(string: value.imageUrl)!)
        }).addDisposableTo(disposeBag)
  }
  
}
