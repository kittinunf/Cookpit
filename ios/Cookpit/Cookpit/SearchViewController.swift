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
  @IBOutlet var noSearchResultLabel: UILabel!

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
    configureNoSearchLabelLabel()
    
    //loadings
    controller.loadings.bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible).addDisposableTo(disposeBag)
    
    //errors
    controller.errors.subscribe(onNext: { [unowned self] value in
      let alert = UIAlertController(title: "Error", message: value, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      if self.presentedViewController == nil {
        self.present(alert, animated: true, completion: nil)
      }
    }).addDisposableTo(disposeBag)

    controller.searchCounts.map { !($0 == 0) }.bind(to: noSearchResultLabel.rx.isHidden).addDisposableTo(disposeBag)
    controller.searchCounts.map { ($0 == 0) }.bind(to: searchResultTableView.rx.isHidden).addDisposableTo(disposeBag)
  }

  func configureBarButtonItems() {
    if let font = UIFont(name: "Menlo", size: 14) {
      cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
      searchBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
    }

    cancelBarButtonItem.rx.tap
      .subscribe(onNext: { [unowned self] value in
        self.searchBar.resignFirstResponder()
      }).addDisposableTo(disposeBag)
    
    self.searchBarButtonItem.rx.tap
      .subscribe(onNext: { [unowned self] value in
        self.searchBar.resignFirstResponder()
      }).addDisposableTo(disposeBag)
  }
  
  func configureSearchBar() {
    searchBar.sizeToFit()
    searchBar.placeholder = "Search"
    
    navigationItem.titleView = searchBar
    
    searchBar.rx.text.filter { $0?.isEmpty ?? false }
      .subscribe(onNext: { [unowned self] value in
        self.controller.fetchRecents()
      }).addDisposableTo(disposeBag)
    
    searchBar.rx.text.map { !($0?.isEmpty ?? false) }.bind(to: recentSearchTableView.rx.isHidden).addDisposableTo(disposeBag)
    searchBar.rx.text.map { $0?.isEmpty ?? false }.bind(to: searchResultTableView.rx.isHidden).addDisposableTo(disposeBag)
    
    searchBar.rx.text.map { $0?.isEmpty ?? false }
      .subscribe(onNext: { [unowned self] value in
        self.navigationItem.rightBarButtonItem = value ? self.cancelBarButtonItem : self.searchBarButtonItem
        if (value) {
          self.noSearchResultLabel.isHidden = true
        }
      }).addDisposableTo(disposeBag)

    searchBar.rx.searchButtonClicked
      .subscribe(onNext: { [unowned self] value in
        self.searchBar.resignFirstResponder()
      }).addDisposableTo(disposeBag)
    
    // search
    searchBar.rx.text.filter { !($0?.isEmpty ?? false) }
      .throttle(0.6, scheduler: MainScheduler.instance)
      .distinctUntilChanged(==)
      .observeOn(SerialDispatchQueueScheduler(qos: DispatchQoS.background))
      .subscribe(onNext: { [unowned self] value in
        guard let value = value else { return }
        self.controller.searchWith(key: value)
      }).addDisposableTo(disposeBag)
    
  }
  
  func configureRecentSearchTableView() {
    recentSearchTableView.frame = view.bounds
    view.addSubview(recentSearchTableView)
    
    let selectedIndexPaths = recentSearchTableView.rx.itemSelected
    
    selectedIndexPaths.map { _ in true }.bind(to: recentSearchTableView.rx.isHidden).addDisposableTo(disposeBag)
    selectedIndexPaths.map { _ in false }.bind(to: searchResultTableView.rx.isHidden).addDisposableTo(disposeBag)
  }
  
  func configureSearchResultTableView() {
    searchResultTableView.frame = view.bounds
    view.addSubview(searchResultTableView)
  }

  func configureNoSearchLabelLabel() {
    noSearchResultLabel.frame = view.bounds
    noSearchResultLabel.isHidden = true
    view.addSubview(noSearchResultLabel)
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
      .subscribe(onNext: { [unowned self] value in
        guard let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Photo") as? PhotoViewController else { return }
        photoViewController.id = value.id
        self.navigationController?.pushViewController(photoViewController, animated: true)
      }).addDisposableTo(disposeBag)
    
    let selectedText = recentSearchTableView.rx.itemSelected
                         .withLatestFrom(viewModel) { indexPath, viewModel in
                            viewModel.recentItems[indexPath.row]
                         }.share()
    
    selectedText.bind(to: self.searchBar.rx.text).addDisposableTo(disposeBag)
    
    selectedText.observeOn(SerialDispatchQueueScheduler(qos: .background))
      .subscribe(onNext: { [unowned self] value in
        self.controller.searchWith(key: value)
      }).addDisposableTo(disposeBag)
  }

  deinit {
    controller.unsubscribe()
  }
  
}
