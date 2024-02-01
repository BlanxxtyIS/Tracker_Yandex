//
//  AllCellFilled.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 31.01.2024.
//

import Foundation

struct AllCellFilled {
    var textField: Bool
    var tableViewCategory: Bool
    var tableViewSchedule: Bool
    var collectionViewEmoji: Bool
    var collectionViewColor: Bool
    
    func allValuesAreTrue() -> Bool {
        return textField && tableViewCategory && tableViewSchedule && collectionViewEmoji && collectionViewColor
    }
}
