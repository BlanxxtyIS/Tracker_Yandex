//
//  IsLoginCoreData+CoreDataClass.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.02.2024.
//
//

import Foundation
import CoreData

@objc(IsLoginCoreData)
public class IsLoginCoreData: NSManagedObject {

}

extension IsLoginCoreData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<IsLoginCoreData> {
        return NSFetchRequest<IsLoginCoreData>(entityName: "IsLoginCoreData")
    }
    @NSManaged public var isLogin: Bool
}

