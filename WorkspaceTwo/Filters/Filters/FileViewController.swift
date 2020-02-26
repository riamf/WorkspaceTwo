//
//  FileViewController.swift
//  Filters
//
//  Created by Pawel Kowalczuk on 25/02/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit
import MyRedux

struct M {
    static let Communication: Middleware<State> = { dispatch, getState in
        return { next in
            return { action in
                if let action = action as? InformListing, let state = getState()?.getStore().last as? FilterQuery  {
                    action.coms?.newQuery(state)
                } else {
                    next(action)
                }
            }
        }
    }
}

public struct FilterQuery: State {
    let selectedFilters: [Int]
    
    public static var `default`: FilterQuery {
        return FilterQuery(selectedFilters: [])
    }
    
    public init(selectedFilters: [Int]) {
        self.selectedFilters = selectedFilters
    }
    public func reduce(_ action: Action) -> State {
        switch action {
        case let tmp as SelectFilter:
            return FilterQuery(selectedFilters: selectedFilters + [tmp.id])
        case let tmp as DeselectFilter:
            var newSelected = selectedFilters
            newSelected.removeAll(where: { $0 == tmp.id })
            return FilterQuery(selectedFilters: newSelected)
        default:
            return self
        }
    }
}

struct InformListing: Action {
    weak var coms: FilterCommunication?
}

struct SelectFilter: Action {
    let id: Int
}
struct DeselectFilter: Action {
    let id: Int
}

class Environment {
    
    static private(set) var `default` = Environment()
    
    init(query: FilterQuery) {
        store = ReduxStore(state: StateStore(store: [query]),
                           reducer: Environment.reducer,
                           middleware: [M.Communication])
    }
    
    init() { }
    
    var store = ReduxStore(state: StateStore(store: [FilterQuery(selectedFilters: [])]),
                           reducer: reducer,
                           middleware: [M.Communication])
    
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

public protocol FilterCommunication: class {
    func newQuery(_ query: FilterQuery)
}

public final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StateChangeObserver {
    
    let dataSource = [1,2,3,4,5,6,7,8,9]
    let table = UITableView(frame: .zero)
    var selectedFilters = [Int]() {
        didSet {
            table.reloadData()
        }
    }
    
    var env = Environment()
    
    public weak var coms: FilterCommunication?
    
    lazy var done: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("show items", for: .normal)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    public init(query: FilterQuery) {
        self.selectedFilters = query.selectedFilters
        env = Environment(query: query)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true) { [weak coms, weak env] in
            env?.store.dispatch(InformListing(coms: coms))
        }
    }
    
    public override func loadView() {
        view = UIView(frame: .zero)
        table.allowsMultipleSelection = true
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        done.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(done)
        
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.bottomAnchor.constraint(equalTo: done.topAnchor),
            
            done.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            done.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            done.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        env.store.add(subscriber: self)
        view.backgroundColor = .green
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL")
        cell.textLabel?.text = "\(indexPath.row)"
        if (selectedFilters.contains(indexPath.row)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedFilters.contains(indexPath.row)) {
            env.store.dispatch(DeselectFilter(id: indexPath.row))
        } else {
            env.store.dispatch(SelectFilter(id: indexPath.row))
        }
    }
    
    public func notify(_ state: StateStore, oldState: StateStore?) {
        selectedFilters = (state.getStore().last as? FilterQuery)?.selectedFilters ?? selectedFilters
    }
}
