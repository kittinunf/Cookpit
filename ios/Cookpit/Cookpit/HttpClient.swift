//
//  Networking.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 5/31/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import Alamofire

class HttpClient {
}

extension HttpClient : CPHttp {
  @objc func get(url: String, observer: CPHttpObserver?) {
      Alamofire.request(.GET, url).validate().responseString { response in
        switch response.result {
          case .Success(let data) :
            observer?.onSuccess(data)
          case .Failure :
            observer?.onFailure()
        }
      }
  }
}
