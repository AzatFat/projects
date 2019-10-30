//
//  GenericTableViewDataSource.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//


import Foundation
import UIKit


final class GenericTableViewDataSource <V, T: Searchable> : NSObject, UITableViewDataSource where V: BaseTableViewCell<T> {
    private var models: [T]
    
    typealias CellConfiguration = (V,T) -> V
    
    private let configureCell: CellConfiguration
    
    private var searchResults: [T] = []
    
    private var isSearchActive: Bool = false
    
    
    init (models: [T], configureCell: @escaping CellConfiguration) {
        self.models = models
        self.configureCell = configureCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? searchResults.count : models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: V = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let model = getModelAt(indexPath)
        return configureCell(cell, model)
    }
    
    
    
    private func getModelAt(_ indexPath: IndexPath) -> T {
        return isSearchActive ? searchResults[indexPath.item] : models[indexPath.item]
    }
    
    var searchDelegate : searchItems<[T]>?
    
    func search(query: String) {
        isSearchActive = !query.isEmpty
        if query != "" {
            if let results = searchDelegate?.searchModel(query: query) {
                searchResults = results
            }
        }
    }
}
