//
//  TrackerCategoryStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 29.01.2024.
//

import UIKit
import CoreData


final class TrackerCategoryStore {
    
    static let shared = TrackerCategoryStore()
    private init() {}
    
    let coreDataManager = CoreDataManager.shared
    let trackerStore = TrackerStore.shared
    
    //MARK: Сохранить TrackerCategory в CoreData
    func addTrackerCategory(trackerCategory: TrackerCategory, trackers: [Tracker]) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: coreDataManager.context)
        trackerCategoryCoreData.id = trackerCategory.id
        trackerCategoryCoreData.header = trackerCategory.header
        for tracker in trackers {
            let trackerCoreData = TrackerCoreData(context: coreDataManager.context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            
            let trackerRecord = TrackerRecordCoreData(context: coreDataManager.context)
            trackerRecord.id = tracker.id
            trackerCoreData.record = trackerRecord
            if !tracker.schedule.isEmpty {
                let schedule = tracker.schedule.map { $0.toData() }
                trackerCoreData.schedule = schedule as NSObject?
            }

            trackerCategoryCoreData.addToTrackers(trackerCoreData)
        }
        do {
            try coreDataManager.saveContext()
        } catch {
            print("Ошибка в TrackerCategoryStore, метод: addTrackerCategory \(error) ")
        }
    }
    
    //MARK: Достать из CoreData
    //Из CoreData TrackerCategoryCoreData по header
    func fetchTrackerCategory(with header: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", header)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            if let firstMatchingCategory = result.first {
                // Запись с таким header существует
                print("Запись c \(header) существует")
                return firstMatchingCategory
            } else {
                // Записи с таким header не существует
                print("Запись с \(header) не существует")
                return nil
            }
        } catch {
            print("Ошибка в TrackerCategoryStore в методе fetchTrackerCategory \(error)")
            return nil
        }
    }
    
    //Из CoreData TrackerCategory по TrackerCategoryCoreData
    func trackerFromCoreData(_ trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        let id = trackerCategoryCoreData.id!
        let header = trackerCategoryCoreData.header!
        
        var trackers: [Tracker] = []
        if let trackerCoreDataObjects = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
            trackers = trackerCoreDataObjects.map { trackerStore.trackerFromCoreData($0) }
        }
        return TrackerCategory(header: header, tracker: trackers, id: id)
    }
    
    //Все значения TrackerCategory
    func getAllTrackerCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()

        do {
            let trackerCategoryCoreDataObjects = try coreDataManager.context.fetch(fetchRequest)
            let trackerCategories = trackerCategoryCoreDataObjects.map { trackerFromCoreData($0) }
            return trackerCategories
        } catch {
            print("Error fetching tracker categories: \(error)")
            return []
        }
    }
    
    //Из CoreData TrackerRecordCoreData по ID
    func fetchTrackerCategory(withID id: UUID) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Ошибка в TrackerRecordStore в методе fetchTracker \(error)")
            return nil
        }
    }
}


