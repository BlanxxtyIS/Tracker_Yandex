//
//  isLoginStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.02.2024.
//

import UIKit
import CoreData

final class IsLoginStore {
    
    static let shared = IsLoginStore()
    init() {}
    
    let coreDataManager = CoreDataManager.shared
    
    func addInfoForLogin(info: Bool) {
        let isLoginCoreData = IsLoginCoreData(context: coreDataManager.context)
        isLoginCoreData.isLogin = info
        do {
            try coreDataManager.saveContext()
        } catch {
            print("Ошибка в TrackerStore при добавлении \(error)")
        }
    }
    
    func fetchAllInfo() -> [IsLoginCoreData] {
        let fetchRequest: NSFetchRequest<IsLoginCoreData> = IsLoginCoreData.fetchRequest()
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result
        } catch {
            print("ERRROR")
            return []
        }
        
    }
}
