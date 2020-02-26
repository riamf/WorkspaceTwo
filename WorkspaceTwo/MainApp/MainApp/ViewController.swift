//
//  ViewController.swift
//  MainApp
//
//  Created by Pawel Kowalczuk on 18/02/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit
import Listing

class ViewController: UIViewController {
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let ctrl = MainListViewController()
        addChild(ctrl)
        view.addSubview(ctrl.view)
        ctrl.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ctrl.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ctrl.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ctrl.view.topAnchor.constraint(equalTo: view.topAnchor),
            ctrl.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        ctrl.didMove(toParent: self)
        
    }


}

extension ViewController: UISearchBarDelegate {
    
}
