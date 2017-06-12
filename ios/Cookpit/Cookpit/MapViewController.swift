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

class MapViewController : UIViewController, MGLMapViewDelegate  {

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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  func configureViews() {
    collectionView.rx.modelSelected(CPMapDetailViewData.self).subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            self.mapView.setCenter(value.coordinate, zoomLevel: 12.0, animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.mapView.selectAnnotation(value, animated: true)
            }
        default:
            break
        }
    }.addDisposableTo(disposeBag)
  }
  
  func bindings() {
    controller = MapDataController()
    
    
    let scheduler = SerialDispatchQueueScheduler(qos: .background)
    let initialCommand = Observable.deferred { [unowned self] in Observable.just(self.controller.request()) }
                                    .subscribeOn(scheduler)
                                    .map { MapViewModelCommand.SetItems(items: []) }
    let loadCommand = controller.viewData.map { MapViewModelCommand.SetItems(items: $0.items) }
    
    let viewModel = Observable.of(initialCommand, loadCommand).concat().scan(MapViewModel(items: [])) { viewModel, command in
        viewModel.executeCommand(command: command)
    }.shareReplay(1)
    
    viewModel.map { $0.items }
        .observeOn(MainScheduler.instance)
        .bind(to: collectionView.rx.items(cellIdentifier: "MapCell", cellType: MapCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    viewModel.map { $0.items }
        .bind(onNext: mapView.addAnnotations)
        .addDisposableTo(disposeBag)
    
    selectedAnnotation.asObservable()
      .withLatestFrom(viewModel) { annotation, viewModel -> IndexPath? in
      guard let viewData = annotation as? CPMapDetailViewData, let index = viewModel.items.index(of: viewData) else { return nil }
      return IndexPath(item: index, section: 0)
    }.filter { $0 != nil }.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            self.collectionView.scrollToItem(at: value!, at: .centeredHorizontally, animated: true)
        default:
            break
        }
    }.addDisposableTo(disposeBag)
  }
  
  deinit {
    controller.unsubscribe()
  }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .infoLight)
    }

    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        guard let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController, let viewData = annotation as? CPMapDetailViewData else { return }
        photoViewController.id = viewData.id
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        selectedAnnotation.value = annotation
    }
    
}
