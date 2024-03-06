//
//  Tracker_HomeTestss.swift
//  Tracker HomeTestss
//
//  Created by Марат Хасанов on 06.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker_Home

final class Tracker_HomeTestss: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewController() {
        let vc = TrackerViewController()
        
        assertSnapshot(matching: vc, as: .image)
    }

}
