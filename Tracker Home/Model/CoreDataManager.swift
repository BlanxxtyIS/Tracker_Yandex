//
//  CoreDataManager.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 29.01.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    //Лениво создаем контейнер СoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription ,error) in
            if let error = error as NSError? {
                fatalError("Ошибка в CoreDataManager \(error)")
            }
        })
        return container
    }()
    
    //Лениво создаем context CoreData
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    //Вспомогательная функция для получения описания сущности по имени
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    //Контроллер для выполнения запросов и отслеживания изменений в CoreData
    func fetchResultController(entityName: String, name: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: name, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //Создание NSFetchedResultController
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    //сохраняем контекст CoreData
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
