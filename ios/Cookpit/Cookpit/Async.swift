//
//  Async.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/10/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation

private let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

func async<T>(background: () -> T,
              main: ((t: T) -> Void)? = nil) {
    dispatch_async(queue) { 
        let t = background()
        guard let main = main else { return }
        dispatch_async(dispatch_get_main_queue()) {
            main(t: t)
        }
    }
}