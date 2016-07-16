//
//  MapViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/10/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController : UIViewController {

  @IBOutlet weak var mapView: MGLMapView!
  
  private var controller: MapDataController!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    controller = MapDataController()
    
    MGLAccountManager.setAccessToken(controller.mapToken)
    
    controller.request()
    controller.viewData.map { $0.items }.subscribeNext { data in
      let locations = data.map { ($0.title, $0.location) }
      for tuple in locations {
        var location = CLLocationCoordinate2D()
        tuple.1.getValue(&location)
        let annotation = MGLPointAnnotation()
        annotation.coordinate = location
        annotation.title = tuple.0
        self.mapView.addAnnotation(annotation)
      }
    }
  }
  
}

extension MapViewController : MGLMapViewDelegate {

  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  func mapView(mapView: MGLMapView, calloutViewForAnnotation annotation: MGLAnnotation) -> UIView? {
    return nil
  }
  
}