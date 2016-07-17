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
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    controller = MapDataController()
    
    MGLAccountManager.setAccessToken(controller.mapToken)
    
    controller.request()
    controller.viewData.map { $0.items }.subscribeNext { data in
      let locations = data.map { ($0.title, $0.location) }
      for tuple in locations {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = tuple.1.coordinate2D()
        annotation.title = tuple.0
        self.mapView.addAnnotation(annotation)
      }
    }.addDisposableTo(disposeBag)
    
    controller.viewData.map { $0.items }.bindTo(collectionView.rx_itemsWithCellIdentifier("MapCell", cellType: MapCollectionViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    collectionView.rx_modelSelected(CPMapDetailViewData.self).subscribeNext { [unowned self] in
      
      self.mapView.setCenterCoordinate($0.location.coordinate2D(), zoomLevel: 12.0, animated: true)
      let selectedTitle = $0.title
      
      let an = self.mapView.annotations?.filter { $0.title ?? "" == selectedTitle }.first
      guard let selected = an else { return }
      
      let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
      dispatch_after(delay, dispatch_get_main_queue()) {
        self.mapView.selectAnnotation(selected, animated: true)
      }
    }.addDisposableTo(disposeBag)
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
    print(annotation) 
  }
  
  func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
    print(annotation)
  }
  
}
