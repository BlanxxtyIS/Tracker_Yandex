//
//  isLoginStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.02.2024.
//

import UIKit

final class AppSettingsStorage {
    
    let key = "IsLoginStore"
    
    static let shared = AppSettingsStorage()
    private init() {}
    
    //Сохранить значение
    func isLogin(condition: Bool) {
        UserDefaults.standard.setValue(condition, forKey: key)
    }
    
    //Узнать значение
    func isLoginCondition() -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
}
