//
//  CategoryStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.02.2024.
//

import UIKit

final class CategoryStore {
    
    let userDefautlts = UserDefaults.standard
    let key = "CategoryKey"
    var categories: [String] = []
    
    static let shared = CategoryStore()
    init() {}
    
    //Сохранить значение
    func categorySave(condition: String) {
        categories = userDefautlts.stringArray(forKey: key) ?? []
        categories.append(condition)
        userDefautlts.setValue(categories, forKey: key)
        userDefautlts.synchronize()
    }
    
    //Получить значения
    func categoryGive() -> [String] {
        return userDefautlts.stringArray(forKey: key) ?? []
    }
}
