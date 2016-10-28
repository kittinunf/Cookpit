//
//  Async.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 7/10/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation

private let queue = DispatchQueue.global(qos: .default)

func dispatchAsync<T>(background: @escaping () -> T,
              main: ((_ t: T) -> Void)? = nil) {
    queue.async {
        let t = background()
        guard let main = main else { return }
        DispatchQueue.main.async  {
            main(t)
        }
    }
}
