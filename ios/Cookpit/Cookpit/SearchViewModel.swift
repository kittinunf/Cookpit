//
//  SearchViewModel.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewModel {

  private let controller = CPSearchController.create()!
  
  private let recentSearch = Variable<[String]>([])
  private let searchResultViewData = Variable<CPSearchViewData?>(nil)
  
  private let loading = Variable<Bool>(false)
  
  lazy var recents: Observable<[String]> = {
    self.recentSearch.asObservable()
  }()
  
  lazy var results: Observable<[CPSearchDetailViewData]> = {
    self.searchResultViewData.asObservable().filter { $0 != nil }.map { $0!.results }
  }()
  
  lazy var loadings: Observable<Bool> = {
    self.loading.asObservable()
  }()
  
  init() {
    controller.subscribe(self)
  }
  
  func searchForKey(key: String) {
    searchForKey(key, page: 1)
  }
  
  func searchNextPage() {
  }
  
  func fetchRecents() {
    recentSearch.value = controller.fetchRecents()
  }
  
  func recentSearchFor(index: Int) -> String {
    return controller.fetchRecents()[index]
  }
  
  private func searchForKey(key: String, page: Int) {
    controller.reset()
    controller.search(key, page: Int8(page))
  }
  
  deinit {
    controller.unsubscribe()
  }
}

extension SearchViewModel : CPSearchControllerObserver {
  @objc func onBeginUpdate() {
    loading.value = true
  }
  
  @objc func onUpdate(viewData: CPSearchViewData) {
    searchResultViewData.value = viewData
  }

  @objc func onEndUpdate() {
    loading.value = false
  }
}