//
//  ViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 5/31/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

  let controller = CPSampleController.create()!

  override func viewDidLoad() {
    super.viewDidLoad()
    controller.subscribe(self)
    
    Alamofire.request(.GET, "https://httpbin.org/get").responseString { response in
      print(response)
    }
  }

}

extension ViewController : CPSampleControllerObserver {
  func onUpdate(viewData: CPSampleViewData) {
    print(viewData.title)
  }
}

