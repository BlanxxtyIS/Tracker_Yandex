//
//  AllCategoryViewModel.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 10.02.2024.
//

import Foundation

class AllCategoryViewModel {
    var categories: [CategoryModel] = []
    
    private let categoryStore = CategoryStore.shared
    
    var reloadTableViewClosure: (() -> Void)?
    
    func loadData() {
        categories = categoryStore.categoryGive().map { CategoryModel(name: $0) }
        reloadTableViewClosure?()
    }
}
