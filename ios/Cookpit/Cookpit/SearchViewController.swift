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
    controller.loadings.bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible).addDisposableTo(disposeBag)
    
    //errors
    controller.errors.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            let alert = UIAlertController(title: "Error", message: value, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            if self.presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }.addDisposableTo(disposeBag)
  }
  
  func configureBarButtonItems() {
    if let font = UIFont(name: "Menlo", size: 14) {
      cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
      searchBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
    }
  
    self.cancelBarButtonItem.rx.tap.subscribe { [unowned self] event in
        switch (event) {
        case .next:
            self.searchBar.resignFirstResponder()
        default:
            break;
        }
    }.addDisposableTo(disposeBag)
    
    self.searchBarButtonItem.rx.tap.subscribe { [unowned self] event in
        switch (event) {
        case .next:
            self.searchBar.resignFirstResponder()
        default:
            break;
        }
    }.addDisposableTo(disposeBag)
  }
  
  func configureSearchBar() {
    searchBar.sizeToFit()
    searchBar.placeholder = "Search"
    
    navigationItem.titleView = searchBar
    
    let searchBarTexts = searchBar.rx.text
    searchBarTexts.filter { $0?.isEmpty ?? false }.subscribe { [unowned self] event in
        switch (event) {
        case .next:
            self.controller.fetchRecents()
        default:
            break
        }
    }.addDisposableTo(disposeBag)
    
    searchBarTexts.map { !($0?.isEmpty ?? false) }.bind(to: recentSearchTableView.rx.isHidden).addDisposableTo(disposeBag)
    searchBarTexts.map { $0?.isEmpty ?? false }.bind(to: searchResultTableView.rx.isHidden).addDisposableTo(disposeBag)
    
    searchBarTexts.map { $0?.isEmpty ?? false }.subscribe { [unowned self] event in
        switch (event) {
        case .next(let value):
            self.navigationItem.rightBarButtonItem = value ? self.cancelBarButtonItem : self.searchBarButtonItem
        default:
            break
        }
    }.addDisposableTo(disposeBag)
    
    searchBar.rx.searchButtonClicked.subscribe { [unowned self] event in
        switch (event) {
        case .next:
            self.searchBar.resignFirstResponder()
        default:
            break
        }
    }.addDisposableTo(disposeBag)
    
    let scheduler = SerialDispatchQueueScheduler(qos: DispatchQoS.background)
    // search
    searchBarTexts
              .filter { !($0?.isEmpty ?? false) }
              .throttle(0.6, scheduler: MainScheduler.instance)
              .distinctUntilChanged(==)
              .observeOn(scheduler)
              .subscribe { [unowned self] event in
                switch (event) {
                case .next(let value):
                    guard let value = value else { return }
                    self.controller.searchWith(key: value)
                default:
                    break
                }
    }.addDisposableTo(disposeBag)
    
  }
  
  func configureRecentSearchTableView() {
    recentSearchTableView.frame = self.view.bounds
    view.addSubview(recentSearchTableView)
    
    let selectedIndexPaths = recentSearchTableView.rx.itemSelected
    
    selectedIndexPaths.map { _ in true }.bind(to: recentSearchTableView.rx.isHidden).addDisposableTo(disposeBag)
    selectedIndexPaths.map { _ in false }.bind(to: searchResultTableView.rx.isHidden).addDisposableTo(disposeBag)
  }
  
  func configureSearchResultTableView() {
    searchResultTableView.frame = self.view.bounds
    view.addSubview(searchResultTableView)
  }
  
  func bindings() {
    let loadSearchCommand = controller.viewData.map { SearchViewModelCommand.SetSearchItems(items: $0.results) }
    let loadRecentCommand = controller.recentItems.map { SearchViewModelCommand.SetRecentItems(items: $0) }
    let resetSearchCommand = searchBar.rx.text.filter { !($0?.isEmpty ?? false) }.map { _ in SearchViewModelCommand.SetSearchItems(items: []) }
    
    let viewModel = Observable.of(loadSearchCommand, loadRecentCommand, resetSearchCommand)
                              .merge()
                              .scan(SearchViewModel(searchItems: [], recentItems: [])) { viewModel, command in
                                viewModel.executeCommand(command: command)
                              }
                              .shareReplay(1)

    viewModel.map { $0.searchItems }
        .bind(to: searchResultTableView.rx.items(cellIdentifier: "SearchResultCell", cellType: SearchTableViewCell.self)) { row, element, cell in
                cell.viewData.value = element
             }
             .addDisposableTo(disposeBag)
    
    viewModel.map { $0.recentItems }
        .bind(to: recentSearchTableView.rx.items(cellIdentifier: "RecentSearchCell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = element
                cell.textLabel?.font = UIFont(name: "Menlo", size: 12.0)
             }
            .addDisposableTo(disposeBag)
    
    searchResultTableView.rx.itemSelected
                         .withLatestFrom(viewModel) { indexPath, viewModel in
                            viewModel.searchItems[indexPath.row]
                         }
                         .subscribe { [unowned self] event in
                            switch (event) {
                            case .next(let value):
                                guard let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController else { return }
                                photoViewController.id = value.id
                                self.navigationController?.pushViewController(photoViewController, animated: true)
                            default:
                                break
                            }
                            
                         }
                         .addDisposableTo(disposeBag)
    
    let selectedText = recentSearchTableView.rx.itemSelected
                         .withLatestFrom(viewModel) { indexPath, viewModel in
                            viewModel.recentItems[indexPath.row]
                         }.share()
    
    selectedText.bind(to: self.searchBar.rx.text).addDisposableTo(disposeBag)
    
    let scheduler = SerialDispatchQueueScheduler(qos: .background)
    selectedText.observeOn(scheduler)
        .subscribe { [unowned self] event in
            switch (event) {
            case .next(let value):
                self.controller.searchWith(key: value)
            default:
                break
            }
        }
        .addDisposableTo(disposeBag)
  }
  
  deinit {
    controller.unsubscribe()
  }
  
}
