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
    
    let scheduler = SerialDispatchQueueScheduler(qos: .background)
    refreshControl.rx.controlEvent(.valueChanged).observeOn(scheduler).subscribe { [unowned self] event in
        switch (event) {
        case .next:
            self.controller.reset()
            self.controller.request(page: 1)
        default:
            break
        }
    }.addDisposableTo(disposeBag)

    //loadings
    controller.loadings.bindTo(refreshControl.rx.refreshing).addDisposableTo(disposeBag)

    controller.loadings.bindTo(UIApplication.shared.rx.isNetworkActivityIndicatorVisible).addDisposableTo(disposeBag)
    
    //errors
    controller.errors.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            let alert = UIAlertController(title: "Error", message: value, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      if self.presentedViewController == nil {
        self.present(alert, animated: true, completion: nil)
      }
        default:
            break
        }
      
    }.addDisposableTo(disposeBag)
  }

  func bindings() {
    let scheduler = SerialDispatchQueueScheduler(qos: .background)
    
    let initialCommand = Observable.deferred { [unowned self] in
        Observable.just(self.controller.request(page: 1))
        }.subscribeOn(scheduler).map { ExploreViewModelCommand.SetItems(items: []) }
    let loadCommand = controller.viewData.map { ExploreViewModelCommand.SetItems(items: $0.explores) }
    
    let viewModel = Observable.of(initialCommand, loadCommand).concat().scan(ExploreViewModel(items: [])) { viewModel, command in
        viewModel.executeCommand(command: command)
      }
      .shareReplay(1)
    
    viewModel.map { $0.items }
        .observeOn(MainScheduler.instance)
        .bindTo(collectionView!.rx.items(cellIdentifier: "ExploreCell", cellType: ExploreCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    
    collectionView!.rx.itemSelected
        .withLatestFrom(viewModel) { indexPath, viewModel in viewModel.items[indexPath.row] }
        .subscribe { [unowned self] event in
            switch (event) {
            case .next(let value):
                guard let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController else { return }
        photoViewController.id = value.id
        self.navigationController?.pushViewController(photoViewController, animated: true)
            default:
                break
            }
        
    }.addDisposableTo(disposeBag)
    
    //load more
    collectionView!.rx_loadMore()
        .withLatestFrom(controller.loadings) { return $0 && !$1 }
        .filter { $0 }
        .throttle(0.3, scheduler: MainScheduler.instance)
        .observeOn(scheduler)
        .subscribe { [unowned self] event in
            switch (event) {
            case .next:
                self.controller.requestNextPage()
            default:
                break
            }
        }.addDisposableTo(disposeBag)
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}

extension ExploreViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width;
    let itemWidth = (width / 2) - 2.5;
    return CGSize(width: itemWidth, height: itemWidth);
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return CGFloat(5)
  }
    
  func collectionView(_ minimumLineSpacingForSectionAtcollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return CGFloat(5)
  }
  
}
