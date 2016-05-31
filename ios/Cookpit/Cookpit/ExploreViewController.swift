//
//  ExploreViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 5/31/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ExploreViewController: UICollectionViewController {

  let controller = CPExploreController.create()!
  
  let viewData = Variable<CPExploreViewData?>(nil)
  
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    controller.subscribe(self)
    controller.request(1)
    
    let items = viewData.asObservable().filter { $0 != nil }.map { $0!.explores }
    
    items.bindTo(collectionView!.rx_itemsWithCellIdentifier("ExploreCell", cellType: ExploreCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
  }
  
}

extension ExploreViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = collectionView.bounds.width;
    let itemWidth = width / 2 - 5;
    return CGSize(width: itemWidth, height: itemWidth);
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
  }
    
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
  }
}

extension ExploreViewController : CPExploreControllerObserver {
  func onUpdate(data: CPExploreViewData) {
    viewData.value = data
  }
}
