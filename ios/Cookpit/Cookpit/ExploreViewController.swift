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

  private let controller = ExploreDataController()
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
    bindings()
  }
  
  func configureViews() {
    //refresh
    let refreshControl = UIRefreshControl()
    collectionView!.addSubview(refreshControl)
    
    let scheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)
    refreshControl.rx_controlEvent(.ValueChanged).observeOn(scheduler).subscribeNext { [unowned self] _ in
      self.controller.reset()
      self.controller.request(1)
    }.addDisposableTo(disposeBag)
    
    //loadings
    controller.loadings.bindTo(refreshControl.rx_refreshing).addDisposableTo(disposeBag)
    controller.loadings.bindTo(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible).addDisposableTo(disposeBag)
    
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
  
  func bindings() {
    let scheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)
    
    let initialCommand = Observable.deferred { [unowned self] in Observable.just(self.controller.request(1)) }.subscribeOn(scheduler).map { ExploreViewModelCommand.SetItems(items: []) }
    let loadCommand = controller.viewData.map { ExploreViewModelCommand.SetItems(items: $0.explores) }
    
    let viewModel = Observable.of(initialCommand, loadCommand).concat().scan(ExploreViewModel(items: [])) { viewModel, command in
        viewModel.executeCommand(command)
      }
      .shareReplay(1)
    
    viewModel.map { $0.items }
        .observeOn(MainScheduler.instance)
        .bindTo(collectionView!.rx_itemsWithCellIdentifier("ExploreCell", cellType: ExploreCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    
    collectionView!.rx_itemSelected
        .withLatestFrom(viewModel) { indexPath, viewModel in viewModel.items[indexPath.row] }
        .subscribeNext { [unowned self] viewData in
        guard let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Photo") as? PhotoViewController else { return }
        photoViewController.id = viewData.id
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }.addDisposableTo(disposeBag)
    
    //load more
    collectionView!.rx_loadMore()
        .withLatestFrom(controller.loadings) { return $0 && !$1 }
        .filter { $0 }
        .throttle(0.3, scheduler: MainScheduler.instance)
        .observeOn(scheduler)
        .subscribeNext { [unowned self] _ in
          self.controller.requestNextPage()
        }.addDisposableTo(disposeBag)
  }
  
  deinit {
    controller.unsubscribe()
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
