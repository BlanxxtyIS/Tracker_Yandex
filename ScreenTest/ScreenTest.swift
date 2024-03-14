//
//  ScreenTest.swift
//  ScreenTest
//
//  Created by Марат Хасанов on 14.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker_Home

final class ScreenTest: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
    }

    func testPerformanceExample() throws {
        measure {
        }
    }
    
    func testViewController() {
        let vc = TrackerViewController()
        
        assertSnapshot(matching: vc, as: .image)
    }

}
