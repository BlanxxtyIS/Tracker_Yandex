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
    func addTrackerRecord(_ tracker: Tracker, date: Date)  {
        let trackerRecordCoreData = TrackerRecordCoreData(context: coreDataManager.context)
        
        trackerRecordCoreData.id = tracker.id
        trackerRecordCoreData.date = date
        do {
            try coreDataManager.context.save()
        } catch {
            print("Ошибка в TrackerStore при добавлении \(error)")
        }
    }
    
    //MARK: Достать из CoreData
    //Из CoreData TrackerRecordCoreData по ID
    func fetchTracker(withID id: UUID) -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Ошибка в TrackerStore в методе fetchTracker \(error)")
            return nil
        }
    }
}
