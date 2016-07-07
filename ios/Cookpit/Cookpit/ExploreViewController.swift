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

class ExploreViewController: UICollectionViewController {

  let controller = ExploreDataController()
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
    bindings()
  }
  
  func configureViews() {
    //refresh
    let refreshControl = UIRefreshControl()
    collectionView!.addSubview(refreshControl)
    
    refreshControl.rx_controlEvent(.ValueChanged).subscribeNext { [unowned self] _ in
      self.controller.reset()
      self.controller.request(1)
    }.addDisposableTo(disposeBag)
    
    controller.loadings.bindTo(refreshControl.rx_refreshing).addDisposableTo(disposeBag)
  }
  
  func bindings() {
    let loadCommand = controller.viewData.map { ExploreViewModelCommand.SetItems(items: $0.explores) }
    
    let viewModel = loadCommand.scan(ExploreViewModel(items: [])) { viewModel, command in
        viewModel.executeCommand(command)
      }
      .shareReplay(1)
    
    viewModel
        .map { $0.items }
        .bindTo(collectionView!.rx_itemsWithCellIdentifier("ExploreCell", cellType: ExploreCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    //load first page
    controller.request(1)
    
    collectionView?.rx_itemSelected.withLatestFrom(viewModel) { indexPath, viewModel in viewModel.items[indexPath.row] }.subscribeNext {
        guard let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Photo") as? PhotoViewController else { return }
        photoViewController.id = $0.id
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }.addDisposableTo(disposeBag)
    
    //load more
    Observable.combineLatest(collectionView!.rx_loadMore(), controller.loadings) {
      return $0 && !$1
    }.filter { $0 }.subscribeNext { [unowned self] _ in
      self.controller.requestNextPage()
    }.addDisposableTo(disposeBag)
    
    //errors
    controller.errors.subscribeNext { [unowned self] message in
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(okAction)
      if self.presentedViewController == nil {
        self.presentViewController(alert, animated: true, completion: nil)
      }
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
    return CGFloat(5)
  }
    
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return CGFloat(5)
  }
  
}
