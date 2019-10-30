//
//  BaseTableVewSearchController.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit



class BaseTableVewSearchController<T: BaseTableViewCell<V>, V>: UITableViewController, UISearchBarDelegate, ReloadData where V: Searchable, V : CellConfigurations {
    
    private var strongDataSource: GenericTableViewDataSource<T, V>?
    
    private var searchController = UISearchController(searchResultsController: nil)

    private var searchType : searchItems<[V]>?
    
    var models: [V] = [] {
        willSet  {
            DispatchQueue.main.async {
                self.strongDataSource = GenericTableViewDataSource(models: self.models, configureCell: { cell, model in
                    cell.item = model
                    return cell
                })
                self.tableView.dataSource = self.strongDataSource
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(T.self)
        tableView.dataSource = self.strongDataSource
        //setUpSearchBar()
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    private func setUpSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        //searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchType = searchType {
            strongDataSource?.searchDelegate = searchType
            strongDataSource?.search(query: searchText)
            self.tableView.reloadData()
        }
    }
    
    func setSearchType(searchType: searchItems<[V]>) {
        self.searchType = searchType
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /** TO DO make cell height configurable*/
        return  models[indexPath.row].cellHeight
    }
    
}

