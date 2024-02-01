//
//  TrackerRecordStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 29.01.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()
    private init() {}
    
    let trackerStore = TrackerStore.shared
    let coreDataManager = CoreDataManager.shared
    
    //конвертируем - добавляем
    func trackerRecordConvert(_ trackerRecord: TrackerRecord) -> TrackerRecordCoreData {
        let trackerRecordCoreData = TrackerRecordCoreData(context: coreDataManager.context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        do {
            try coreDataManager.saveContext()
        } catch {
            print("Ошибка в TrackerStore при добавлении \(error)")
        }
        return trackerRecordCoreData
    }
    
    //удаляем
    func removeRecord(forId id: UUID, onDate date: Date) {
        let context = coreDataManager.context
        
        let startDate = Calendar.current.startOfDay(for: date)
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@", id as CVarArg, startDate as CVarArg, startDate.addingTimeInterval(24 * 60 * 60) as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            for trackerRecord in result {
                context.delete(trackerRecord)
            }
            try coreDataManager.saveContext()
            print("удалили \(id) на дату \(date)")
        } catch {
            print("Ошибка удаления записи \(error)")
        }
    }
    
    //поулчаем все
    func fetchAllRecord() -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result
        } catch {
            print("ERRROR")
            return []
        }
        
    }
    
}
