//
//  SearchViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

enum SearchViewModelCommand {

  case SetSearchItems(items: [CPSearchDetailViewData])
  case SetRecentItems(items: [String])
  
}

struct SearchViewModel {

  let searchItems: [CPSearchDetailViewData]
  let recentItems: [String]
  
  func executeCommand(command: SearchViewModelCommand) -> SearchViewModel {
    switch command {
    case let .SetSearchItems(items):
        return SearchViewModel(searchItems: items, recentItems: recentItems)
    case let .SetRecentItems(items):
        return SearchViewModel(searchItems: searchItems, recentItems: items)
    }
  }
  
}
