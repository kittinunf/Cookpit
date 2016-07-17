//
//  MapViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/10/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import Mapbox
import RxCocoa
import RxSwift

class MapViewController : UIViewController {

  @IBOutlet weak var mapView: MGLMapView!
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var controller: MapDataController!
  
  private let disposeBag = DisposeBag()
  
  private let selectedAnnotation = Variable<MGLAnnotation?>(nil)
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
    bindings()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  func configureViews() {
    collectionView.rx_modelSelected(CPMapDetailViewData.self).subscribeNext { [unowned self] data in
      self.mapView.setCenterCoordinate(data.coordinate, zoomLevel: 12.0, animated: true)
      
      let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5*Double(NSEC_PER_SEC)))
      dispatch_after(delay, dispatch_get_main_queue()) {
        self.mapView.selectAnnotation(data, animated: true)
      }
    }.addDisposableTo(disposeBag)
  }
  
  func bindings() {
    controller = MapDataController()
    
    MGLAccountManager.setAccessToken(controller.mapToken)
    
    let scheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)
    let initialCommand = Observable.deferred { [unowned self] in Observable.just(self.controller.request()) }
                                    .subscribeOn(scheduler)
                                    .map { MapViewModelCommand.SetItems(items: []) }
    let loadCommand = controller.viewData.map { MapViewModelCommand.SetItems(items: $0.items) }
    
    let viewModel = Observable.of(initialCommand, loadCommand).concat().scan(MapViewModel(items: [])) { viewModel, command in
      viewModel.executeCommand(command)
    }.shareReplay(1)
    
    viewModel.map { $0.items }
        .observeOn(MainScheduler.instance)
        .bindTo(collectionView.rx_itemsWithCellIdentifier("MapCell", cellType: MapCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    viewModel.map { $0.items }
        .bindNext(mapView.addAnnotations)
        .addDisposableTo(disposeBag)
    
    selectedAnnotation.asObservable()
      .withLatestFrom(viewModel) { annotation, viewModel in
      guard let viewData = annotation as? CPMapDetailViewData, index = viewModel.items.indexOf(viewData) else { return NSIndexPath(forItem: -1, inSection: 0) }
      return NSIndexPath(forItem: index, inSection: 0)
    }.filter { $0.item != -1 }.subscribeNext { [unowned self] indexPath in
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
    }.addDisposableTo(disposeBag)
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}

extension MapViewController : MGLMapViewDelegate {

  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
    return UIButton(type: .InfoLight)
  }
  
  func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    guard let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Photo") as? PhotoViewController, viewData = annotation as? CPMapDetailViewData else { return }
        photoViewController.id = viewData.id
    self.navigationController?.pushViewController(photoViewController, animated: true)
  }
  
  func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
    selectedAnnotation.value = annotation
  }
  
}
