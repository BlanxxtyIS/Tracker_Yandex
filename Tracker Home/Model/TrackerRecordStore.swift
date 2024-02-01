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
    
    let coreDataManager = CoreDataManager.shared
    
    //MARK: Сохранить TrackerRecord в CoreData
    func addTrackerRecord(_ trackerId: UUID, count completedDaysCount: Int, button isButtonChecked: Bool)  {
        let trackerRecordCoreData = TrackerRecordCoreData(context: coreDataManager.context)
        
        trackerRecordCoreData.id = trackerId
        trackerRecordCoreData.completedDaysCount = Int16(completedDaysCount)
        trackerRecordCoreData.isButtonChecked = isButtonChecked
        do {
            try coreDataManager.context.save()
        } catch {
            print("Ошибка в TrackerStore при добавлении \(error)")
        }
    }
    
    //MARK: Достать из CoreData
    //Из CoreData TrackerRecordCoreData по ID
    func fetchTrackerRecord(withID id: UUID) -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Ошибка в TrackerRecordStore в методе fetchTracker \(error)")
            return nil
        }
    }
    
    //Удалить из CoreData
    func deleteRecord(withID id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id== %@", id as CVarArg)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            
            for item in result {
                coreDataManager.context.delete(item)
            }
            try coreDataManager.saveContext()
        } catch {
            print("Ошибка при сохранении удаления \(error)")
        }
    }
    
    //Все значения TrackerRecord
    func getAllTrackerRecords() -> [TrackerRecordCoreData]? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        do {
            let trackerRecords = try coreDataManager.context.fetch(fetchRequest)
            return trackerRecords
        } catch {
            print("Ошибка при получении TrackerRecordCoreData: \(error)")
            return nil
        }
    }

}
