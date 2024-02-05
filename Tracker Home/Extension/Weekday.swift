//
//  Weekday.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 09.01.2024.
//

import Foundation

enum Weekday: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
}

extension Weekday {
    func toData() -> Data {
        let rawValueData = withUnsafeBytes(of: rawValue) { Data($0) }
        return rawValueData
    }

    static func fromData(_ data: Data) -> Weekday? {
        guard data.count == MemoryLayout<Int>.size else {
            return nil
        }
        let rawValue = data.withUnsafeBytes { $0.load(as: Int.self) }
        return Weekday(rawValue: rawValue)
    }
}

