//
//  ListingViewController.swift
//  Listing
//
//  Created by Pawel Kowalczuk on 24/02/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit
import MyRedux
import Filters

class ListingViewController: UIViewController, FilterCommunication {
    var table: UITableView!
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()
    
    lazy var filtersButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Filters", for: .normal)
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()
    
    var filters: FilterQuery!
    
    init(phrase: String, filters: FilterQuery) {
        self.filters = filters
        super.init(nibName: nil, bundle: nil)
        searchController.searchBar.text = phrase
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = UIView(frame: .zero)
        table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        Environment.default.store.add(subscriber: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
        style: .plain,
        target: self,
        action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filtersButton)
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
        Environment.default.store.dispatch(PopSearch())
    }
    
    @objc private func showFilters() {
        let ctrl = FiltersViewController(query: filters)
        ctrl.coms = self
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true, completion: nil)
    }
    
    func newQuery(_ query: FilterQuery) {
        Environment.default.store.dispatch(NewFilterSearch(filters: query))
        let phrase = searchController.searchBar.text ?? ""
        navigationController?.pushViewController(ListingViewController(phrase: phrase, filters: query), animated: true)
    }
}

extension ListingViewController: StateChangeObserver {
    public func notify(_ state: StateStore, oldState: StateStore?) {
        guard let queries = (state.getStore() as? [ListQueryStore])?.first?.queries,
            queries.count - 2 >= 0 else {
            return
        }
        
        searchController.isActive = false
        searchController.searchBar.text = queries[queries.count - 2].phrase
    }
}

extension ListingViewController: UITableViewDataSource, UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let phrase = searchBar.text ?? ""
        navigationController?.pushViewController(ListingViewController(phrase: phrase, filters: filters), animated: true)
        Environment.default.store.dispatch(NewSearch(phrase: phrase))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
