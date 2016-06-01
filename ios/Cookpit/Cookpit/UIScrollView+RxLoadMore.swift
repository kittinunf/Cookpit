//
//  UIScrollView+RxLoadMore.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift

extension UIScrollView {
  func rx_loadMore() -> Observable<Bool> {
    return rx_contentOffset.asObservable().map { [unowned self] offset in
      let contentHeight = self.contentSize.height
      
      if offset.y > (contentHeight - self.bounds.height) {
        return true
      } else {
        return false
      }
    }
  }
}


