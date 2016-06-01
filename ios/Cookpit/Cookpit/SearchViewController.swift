//
//  SearchViewController.swift
//  Cookpit
//
//  Created by Kittinun Vantasin on 6/1/16.
//  Copyright © 2016 Cookpit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController : UIViewController {

  let viewModel = SearchViewModel()
  
  @IBOutlet var searchBarButtonItem: UIBarButtonItem!
  @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
  
  @IBOutlet var searchBar: UISearchBar!
  
  @IBOutlet var recentSearchTableView: UITableView!
  @IBOutlet var searchResultTableView: UITableView!
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
  }
  
  func configureViews() {
    configureBarButtonItems()
    configureSearchBar()
    configureRecentSearchTableView()
    configureSearchResultTableView()
    
    viewModel.loadings.subscribeNext {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = $0
    }.addDisposableTo(disposeBag)
  }
  
  func configureBarButtonItems() {
    if let font = UIFont(name: "Menlo", size: 14) {
      cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
      searchBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
    }
  
    self.cancelBarButtonItem.rx_tap.subscribeNext { [unowned self] _ in
      self.searchBar.resignFirstResponder()
    }.addDisposableTo(disposeBag)
    
    self.searchBarButtonItem.rx_tap.subscribeNext { [unowned self] _ in
      self.searchBar.resignFirstResponder()
    }.addDisposableTo(disposeBag)
  }
  
  func configureSearchBar() {
    searchBar.sizeToFit()
    searchBar.placeholder = "Search"
    
    navigationItem.titleView = searchBar
    
    let searchBarTexts = searchBar.rx_text
    searchBarTexts.filter { $0.isEmpty }.subscribeNext { [unowned self] _ in
      self.viewModel.fetchRecents()
    }.addDisposableTo(disposeBag)
    
    searchBarTexts.map { !$0.isEmpty }.bindTo(recentSearchTableView.rx_hidden).addDisposableTo(disposeBag)
    searchBarTexts.map { $0.isEmpty }.bindTo(searchResultTableView.rx_hidden).addDisposableTo(disposeBag)
    
    searchBarTexts.map { $0.isEmpty }.subscribeNext { [unowned self] empty in
      self.navigationItem.rightBarButtonItem = empty ? self.cancelBarButtonItem : self.searchBarButtonItem
    }.addDisposableTo(disposeBag)
    
    searchBar.rx_searchButtonClicked.subscribeNext { [unowned self] _ in
      self.searchBar.resignFirstResponder()
    }.addDisposableTo(disposeBag)
    
    // search
    searchBarTexts
              .filter { !$0.isEmpty }
              .throttle(0.5, scheduler: MainScheduler.instance)
              .distinctUntilChanged()
              .subscribeNext { [unowned self] text in
              self.viewModel.searchForKey(text)
    }.addDisposableTo(disposeBag)
    
  }
  
  func configureRecentSearchTableView() {
    recentSearchTableView.frame = self.view.bounds
    view.addSubview(recentSearchTableView)
    
    viewModel.recents.bindTo(recentSearchTableView.rx_itemsWithCellIdentifier("RecentSearchCell", cellType: UITableViewCell.self)) { row, element, cell in
      cell.textLabel?.text = element
      cell.textLabel?.font = UIFont(name: "Menlo", size: 12.0)
    }.addDisposableTo(disposeBag)
    
    let selectedIndexPaths = recentSearchTableView.rx_itemSelected
    
    selectedIndexPaths.map { _ in true }.bindTo(recentSearchTableView.rx_hidden).addDisposableTo(disposeBag)
    selectedIndexPaths.map { _ in false }.bindTo(searchResultTableView.rx_hidden).addDisposableTo(disposeBag)
    
    selectedIndexPaths.subscribeNext { [unowned self] indexPath in
      let selectedText = self.viewModel.recentSearchFor(indexPath.row)
      self.searchBar.text = selectedText
      self.viewModel.searchForKey(selectedText)
    }.addDisposableTo(disposeBag)
  }
  
  func configureSearchResultTableView() {
    searchResultTableView.frame = self.view.bounds
    view.addSubview(searchResultTableView)
    viewModel.results.bindTo(searchResultTableView.rx_itemsWithCellIdentifier("SearchResultCell", cellType: SearchTableViewCell.self)) { row, element, cell in
      cell.viewData.value = element
    }.addDisposableTo(disposeBag)
    
    searchResultTableView.rx_itemSelected.subscribeNext { [unowned self] indexPath in
      print(indexPath.row)
    }.addDisposableTo(disposeBag)
  }
  
}
