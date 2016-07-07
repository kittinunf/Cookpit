//
//  ExploreViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation

enum ExploreViewModelCommand {

  case SetItems(items: [CPExploreDetailViewData])
  
}

struct ExploreViewModel {

  let items: [CPExploreDetailViewData]
  
  func executeCommand(command: ExploreViewModelCommand) -> ExploreViewModel {
    switch command {
    case let .SetItems(items):
        return ExploreViewModel(items: items)
    }
  }
  
}