//
//  MainListViewController.swift
//  Listing
//
//  Created by Pawel Kowalczuk on 20/02/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit
import MyRedux
import Filters

struct NewSearch: Action {
    let phrase: String
}
struct PopSearch: Action {}
struct NewFilterSearch: Action {
    let filters: FilterQuery
}

struct ListQueryStore: State {
    let queries: [ListQuery]
    
    func reduce(_ action: Action) -> State {
        
        switch action {
        case let tmp as NewSearch:
            return ListQueryStore(queries: queries + [ListQuery(phrase: tmp.phrase, filters: queries.last!.filters)])
        case _ as PopSearch:
            var newQueries = queries
            _ = newQueries.popLast()
            return ListQueryStore(queries: newQueries)
        case let tmp as NewFilterSearch:
            return ListQueryStore(queries: [ListQuery(phrase: queries.last!.phrase, filters: tmp.filters)])
        default:
            return self
        }
    }
}

struct ListQuery: State {
    let phrase: String
    let filters: FilterQuery //FilterQuery(selectedFilters: [])
    
    func reduce(_ action: Action) -> State {
        return self
    }
}

class UseCases {
    func search(with phrase: String) {
        Environment.default.store.dispatch(NewSearch(phrase: phrase))
    }
}

class Environment {
    
    static private(set) var `default` = Environment()
    
    let store = ReduxStore(state: StateStore(store: [ListQueryStore(queries: [ListQuery(phrase: "", filters: FilterQuery(selectedFilters: []))])]),
                           reducer: reducer,
                           middleware: [])
    
    static func reducer(action: Action, state: StateStore?) -> StateStore {
        guard let state = state else {
            return StateStore(store: [])
        }
        let store = state.getStore().map {
            $0.reduce(action)
        }
        return StateStore(store: store)
    }
}

public final class MainListViewController: UIViewController {
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Environment.default.store.add(subscriber: self)
        view.backgroundColor = .red
        
        parent?.navigationItem.searchController = searchController
        searchController.searchBar.text = "wow search"
        parent?.definesPresentationContext = true
    }
}

extension MainListViewController: StateChangeObserver {
    public func notify(_ state: StateStore, oldState: StateStore?) {
        
    }
}

extension MainListViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let phrase = searchBar.text ?? ""
        Environment.default.store.dispatch(NewSearch(phrase: phrase))
        navigationController?.pushViewController(ListingViewController(phrase: phrase, filters: FilterQuery.default), animated: true)
    }
}
