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

  let viewModel = ExploreViewModel()
  var disposeBag = DisposeBag()
  
  // views
  let refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.requestForPage(1)
    configureViews()
    bindings()
  }
  
  func configureViews() {
    guard let collectionView = collectionView else { return }
    collectionView.addSubview(refreshControl)
    
    //reload
    refreshControl.rx_controlEvent(.ValueChanged).subscribeNext { [unowned self] _ in
      self.viewModel.reset()
      self.viewModel.requestForPage(1)
    }.addDisposableTo(disposeBag)
    
    //load more
    Observable.combineLatest(collectionView.rx_loadMore(), viewModel.loadings) {
      return $0 && !$1
    }.filter { $0 }.subscribeNext { [unowned self] _ in
      self.viewModel.requestForNextPage()
    }.addDisposableTo(disposeBag)
    
    //error
    viewModel.errors.subscribeNext { [unowned self] message in
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(okAction)
      if self.presentedViewController == nil {
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }.addDisposableTo(disposeBag)
    
  }
  
  func bindings() {
    //loadings
    viewModel.loadings.bindTo(refreshControl.rx_refreshing).addDisposableTo(disposeBag)
    
    //items
    viewModel.items.bindTo(collectionView!.rx_itemsWithCellIdentifier("ExploreCell", cellType: ExploreCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
  }
  
}

extension ExploreViewController : UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let width = collectionView.bounds.width;
    let itemWidth = (width / 2) - 2.5;
    return CGSize(width: itemWidth, height: itemWidth);
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(viewModel.spacingForSection(section))
  }
    
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(viewModel.spacingForSection(section))
  }
  
}
