//
//  TrackerStore.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 29.01.2024.
//

import UIKit
import CoreData


final class TrackerStore {
    
    static let shared = TrackerStore()
    private init() {}
    
    let coreDataManager = CoreDataManager.shared
    
    //convert
    func trackerConvert(_ tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: coreDataManager.context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.createdDate = Date()
        if !tracker.schedule.isEmpty {
            let schedule = tracker.schedule.map { $0.toData() }
            trackerCoreData.schedule = schedule as NSObject?
        }
        return trackerCoreData
    }
    
    //MARK: Сохранить Tracker в CoreData
    func addTracker(_ tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData)  {
        let trackerCoreData = TrackerCoreData(context: coreDataManager.context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.createdDate = Date()
        if !tracker.schedule.isEmpty {
            let schedule = tracker.schedule.map { $0.toData() }
            trackerCoreData.schedule = schedule as NSObject?
        }
        trackerCategoryCoreData.addToTrackers(trackerCoreData)
        do {
            try coreDataManager.saveContext()
        } catch {
            print("Ошибка в TrackerStore при добавлении \(error)")
        }
    }
        
    //MARK: Достать из CoreData
    //Из CoreData TrackerCoreData по ID
    func fetchTracker(withID id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Ошибка в TrackerStore в методе fetchTracker \(error)")
            return nil
        }
    }
    
    //Все значения Tracker
    func getAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()

        do {
            let trackerCoreDataObjects = try coreDataManager.context.fetch(fetchRequest)
            let tracker = trackerCoreDataObjects.map { trackerFromCoreData($0) }
            return tracker
        } catch {
            print("Error fetching tracker categories: \(error)")
            return []
        }
    }
    
    //Из CoreData Tracker по ID
    func trackerFromCoreData(_ trackerCoreData: TrackerCoreData) -> Tracker {
        let id = trackerCoreData.id!
        let name = trackerCoreData.name!
        let color = trackerCoreData.color as! UIColor
        let emoji = trackerCoreData.emoji!
        
        var schedule: [Weekday] = []
        if let scheduleData = trackerCoreData.schedule as? [Data] {
            schedule = scheduleData.compactMap { Weekday.fromData($0) }
        }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    //Добавлении трэкера в категорию
    func addTrackerToCategory(tracker: TrackerCoreData, category: TrackerCategoryCoreData) {
        let trackers = category.mutableSetValue(forKey: "trackers")
        trackers.add(tracker)
        
        do {
            try coreDataManager.context.save()
        } catch {
            print("Ошибка в TrackerStore в методе addTrackerToCategory \(error)")
        }
    }
}

//как связать 1-1
//let trackerCategory = TrackerCategoryCoreData(context: context)
//tracker.category = trackerCategory

//как связать 1-many
//trackerCategpry.addToTrackers(tracker)

//Удалить context.delete(tracker)

//Изменить
//let managedID = id
//let object = try context.exitstingObject(with: managedID) as! TrackerCoreData //получаем ID
//object?.name = "Василий" //меняем
