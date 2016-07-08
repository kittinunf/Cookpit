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

  @IBOutlet var searchBarButtonItem: UIBarButtonItem!
  @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var recentSearchTableView: UITableView!
  @IBOutlet var searchResultTableView: UITableView!
  
  private let controller = SearchDataController()
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureViews()
    bindings()
  }
  
  func configureViews() {
    configureBarButtonItems()
    configureSearchBar()
    configureRecentSearchTableView()
    configureSearchResultTableView()
    
    //loadings
    controller.loadings.bindTo(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible).addDisposableTo(disposeBag)
    
    //errors
    controller.errors.subscribeNext { [unowned self] message in
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(okAction)
      if self.presentedViewController == nil {
        self.presentViewController(alert, animated: true, completion: nil)
      }
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
      self.controller.fetchRecents()
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
              .throttle(0.6, scheduler: MainScheduler.instance)
              .distinctUntilChanged()
              .subscribeNext { [unowned self] text in
                self.controller.searchWith(text)
    }.addDisposableTo(disposeBag)
    
  }
  
  func configureRecentSearchTableView() {
    recentSearchTableView.frame = self.view.bounds
    view.addSubview(recentSearchTableView)
    
    let selectedIndexPaths = recentSearchTableView.rx_itemSelected
    
    selectedIndexPaths.map { _ in true }.bindTo(recentSearchTableView.rx_hidden).addDisposableTo(disposeBag)
    selectedIndexPaths.map { _ in false }.bindTo(searchResultTableView.rx_hidden).addDisposableTo(disposeBag)
  }
  
  func configureSearchResultTableView() {
    searchResultTableView.frame = self.view.bounds
    view.addSubview(searchResultTableView)
  }
  
  func bindings() {
    let loadSearchCommand = controller.viewData.map { SearchViewModelCommand.SetSearchItems(items: $0.results) }
    let loadRecentCommand = controller.recentItems.map { SearchViewModelCommand.SetRecentItems(items: $0) }
    let resetSearchCommand = searchBar.rx_text.filter { !$0.isEmpty }.map { _ in SearchViewModelCommand.SetSearchItems(items: []) }
    
    let viewModel = Observable.of(loadSearchCommand, loadRecentCommand, resetSearchCommand)
                              .merge()
                              .scan(SearchViewModel(searchItems: [], recentItems: [])) { viewModel, command in
        viewModel.executeCommand(command)
      }
      .shareReplay(1)
    
    viewModel.map { $0.searchItems }
             .bindTo(searchResultTableView.rx_itemsWithCellIdentifier("SearchResultCell", cellType: SearchTableViewCell.self)) { row, element, cell in
                cell.viewData.value = element
             }
             .addDisposableTo(disposeBag)
    
    viewModel.map { $0.recentItems }
             .bindTo(recentSearchTableView.rx_itemsWithCellIdentifier("RecentSearchCell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element
                cell.textLabel?.font = UIFont(name: "Menlo", size: 12.0)
             }
            .addDisposableTo(disposeBag)
    
    searchResultTableView.rx_itemSelected
                         .withLatestFrom(viewModel) { indexPath, viewModel in
                            viewModel.searchItems[indexPath.row]
                         }
                         .subscribeNext { [unowned self] viewData in
                            guard let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Photo") as? PhotoViewController else { return }
                            photoViewController.id = viewData.id
                            self.navigationController?.pushViewController(photoViewController, animated: true)
                         }
                         .addDisposableTo(disposeBag)
    
    recentSearchTableView.rx_itemSelected
                         .withLatestFrom(viewModel) { indexPath, viewModel in
                            viewModel.recentItems[indexPath.row]
                         }
                         .subscribeNext { [unowned self] text in
                            self.searchBar.text = text
                            self.controller.searchWith(text)
                         }
                         .addDisposableTo(disposeBag)
  }
  
}
