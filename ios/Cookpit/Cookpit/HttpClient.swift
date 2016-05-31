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
  @objc func get(url: String, params: [String : String]?, observer: CPHttpObserver?) {
      var modifiedParams = params
  
      if modifiedParams != nil {
        modifiedParams!["format"] = "json"
        modifiedParams!["nojsoncallback"] = "1"
      }
  
      Alamofire.request(.GET, url, parameters: modifiedParams).validate().responseString { response in
        switch response.result {
          case .Success(let data) :
            observer?.onSuccess(data)
          case .Failure :
            observer?.onFailure()
        }
      }
  }
}
