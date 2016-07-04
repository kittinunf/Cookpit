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
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let token = "pk.eyJ1Ijoia2l0dGludW5mIiwiYSI6ImNpcTZyY2MwODAwaDBmcW02N3JweTk3M2wifQ.zM0-aialUeNtcCslIVG1ow"
    MGLAccountManager.setAccessToken(token)
    
    let center = CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407)
    mapView.setCenterCoordinate(center, zoomLevel: 10, animated: false)
    
    let annotation = MGLPointAnnotation()
    annotation.coordinate = center
    annotation.title = "Hello"
    
    mapView.addAnnotation(annotation)
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